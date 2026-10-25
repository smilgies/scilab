"""indexGIXS - indexing of grazing-incidence X-ray scattering patterns.

Python / tkinter version for the Raspberry Pi. Loads a 32-bit greyscale TIFF
detector image (logarithmic intensity, jet colour map) and overlays the
calculated Bragg reflections of a 2D powder with a given lattice, texture
plane, space-group rules and set-up (see Smilgies, Crystals 15, 63 (2025) and
Smilgies & Li, J. Appl. Cryst. 59, 960 (2026)).
"""
import copy
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

import numpy as np
import matplotlib
from PIL import Image, ImageTk

VIEW_SIZE = 700      # image display area (pixels)
WIN_SIZE = 1000      # window size (pixels)
# Settings that the "index rule" menu will control (see find_hkl.sci):
# maximum indices, screw axes along [100], [010], [001], glide planes
# perpendicular to a, b, c, and the side of the incident plane (L, R or B)
DEFAULT_SG = {"hmax": 5, "kmax": 5, "lmax": 5,
              "screw": (1, 1, 1),
              "glide": ("none", "none", "none"),
              "side": "B",
              "search": "real"}      # "real" or "rec" (reciprocal surface cell)
RULE_BG = "#d9b8f5"                  # light purple of the index rule button
LOAD_BG = "#32cd32"                  # lime green of the Load button

# Plot style (the "spot" menu, see get_plot_info.sci). Colours: blk, red, grn,
# blu, cya, mag, yel, wht, none, or any Tk colour name / #rrggbb.
COLOUR_NAMES = {"blk": "black", "red": "red", "grn": "#00ff00", "blu": "blue",
                "cya": "cyan", "mag": "magenta", "yel": "yellow", "wht": "white"}
SYMBOLS = ["circ", "squ", "up", "down", "dia", "+", "x", "*"]
LINE_STYLES = ["none", "solid", "dash", "dot"]
LINE_DASH = {"solid": None, "dash": (6, 4), "dot": (2, 3)}
TEXT_STYLES = ["normal", "italics", "bold"]
FONT_PT = {1: 7, 2: 8, 3: 9, 4: 11, 5: 13}      # text size 1-5 -> points
DEFAULT_STYLE = {
    "spots":   {"symbol": "dia", "size": 10, "rim": "mag", "fill": "none"},
    "rspots":  {"symbol": "dia", "size": 8, "rim": "cya", "fill": "none"},
    "text":    {"style": "normal", "size": 2, "color": "wht", "offset": 8},
    "beams":   {"symbol": "*", "size": 14, "rim": "grn", "fill": "none"},
    "horizon": {"style": "solid", "width": 2, "color": "yel"},
    "yonedaF": {"style": "solid", "width": 2, "color": "red"},
    "yonedaS": {"style": "dash", "width": 2, "color": "red"},
    "cbar_size": 3,
}
CBAR_W = 560         # colour bar width (pixels)
CBAR_H = 18          # colour bar height (pixels)
CBAR_AREA_H = 90     # height of the canvas holding colour bar, ticks and labels
MAX_LABELS = 600     # the index button labels at most this many spots
Z_FROM_BOTTOM = True # True: z0 is counted upwards from the bottom image row
                     # (as in calc_spots.sci: z = z0 + ...); False: from the top


# =============================================================================
# Image handling
# =============================================================================
def decode_colour(text):
    """Colour abbreviation / name / #rrggbb -> Tk colour; '' means none."""
    text = str(text).strip()
    if text.lower() in ("", "none"):
        return ""
    return COLOUR_NAMES.get(text.lower(), text)


def short_number(value):
    """4 significant digits; exponents written as 1e7 instead of 1e+07."""
    text = "{:.4g}".format(value)
    if "e" in text:
        mantissa, exponent = text.split("e")
        text = "{}e{}".format(mantissa, int(exponent))
    return text


def load_tiff(path, size):
    """Read a 32-bit greyscale TIFF and return the linear intensity data
    scaled to fit size x size (float32), plus the original size and the
    smallest positive / largest intensity of the full-resolution image."""
    with Image.open(path) as img:
        data = np.array(img, dtype=np.float64)

    if data.ndim > 2:            # unexpected multi-channel file: use channel 0
        data = data[..., 0]

    positive = data > 0
    if not positive.any():
        raise ValueError("Image contains no positive intensity values.")
    pos_min = float(data[positive].min())
    data_max = float(data.max())

    # Scale to fit the display area, keeping the aspect ratio
    h, w = data.shape
    scale = size / max(h, w)
    new_w = max(1, int(round(w * scale)))
    new_h = max(1, int(round(h * scale)))
    small = Image.fromarray(data.astype(np.float32)).resize(
        (new_w, new_h), Image.BILINEAR)

    return np.asarray(small, dtype=np.float32), (w, h), pos_min, data_max


def render_jet_log(data, vmin, vmax):
    """Clip intensities to [vmin, vmax], take log10, map to jet -> RGB image."""
    clipped = np.clip(data, vmin, vmax)
    log_data = np.log10(clipped)
    lo, hi = np.log10(vmin), np.log10(vmax)
    norm = (log_data - lo) / (hi - lo)
    rgba = matplotlib.colormaps["jet"](norm, bytes=True)
    return Image.fromarray(rgba[..., :3], mode="RGB")


# =============================================================================
# Reflection calculation (pseudo-z-axis geometry, Smilgies, Crystals 15, 63)
# =============================================================================
def reciprocal_matrix(a, b, c, alf, bet, gam):
    """Busing-Levy matrix: its columns are the reciprocal lattice vectors
    A*, B*, C* (with the 2*pi convention, in 1/nm if a, b, c are in nm)."""
    ca, cb, cg = np.cos(np.radians([alf, bet, gam]))
    sa, sb, sg = np.sin(np.radians([alf, bet, gam]))

    arg = 1.0 - ca**2 - cb**2 - cg**2 + 2.0 * ca * cb * cg
    if arg <= 0:
        raise ValueError("The lattice angles do not give a valid unit cell.")
    vol = a * b * c * np.sqrt(arg)

    a_s = 2 * np.pi * b * c * sa / vol
    b_s = 2 * np.pi * c * a * sb / vol
    c_s = 2 * np.pi * a * b * sg / vol

    cos_as = (cb * cg - ca) / (sb * sg)
    cos_bs = (cg * ca - cb) / (sg * sa)
    cos_cs = (ca * cb - cg) / (sa * sb)
    sin_bs = np.sqrt(1.0 - cos_bs**2)
    sin_cs = np.sqrt(1.0 - cos_cs**2)

    A = np.array([a_s, 0.0, 0.0])
    B = np.array([b_s * cos_cs, b_s * sin_cs, 0.0])
    C = np.array([c_s * cos_bs, -c_s * sin_bs * ca, 2 * np.pi / c])
    return np.array([A, B, C]).T


def rotation_to_z(vec):
    """Rotation matrix that turns the vector vec into the +z direction."""
    g = vec / np.linalg.norm(vec)
    z = np.array([0.0, 0.0, 1.0])
    v = np.cross(g, z)
    s = np.linalg.norm(v)
    c = float(np.dot(g, z))
    if s < 1e-12:
        return np.eye(3) if c > 0 else np.diag([1.0, -1.0, -1.0])
    vx = np.array([[0, -v[2], v[1]],
                   [v[2], 0, -v[0]],
                   [-v[1], v[0], 0]])
    return np.eye(3) + vx + vx @ vx * ((1.0 - c) / s**2)


def surface_matrix(aspar, bspar, gamspar, asperp, bsperp, csperp):
    """Reciprocal surface cell -> matrix whose columns are the vectors
    (aspar, 0, asperp), (bspar cos(gamspar), bspar sin(gamspar), bsperp) and
    (0, 0, csperp), as in calc_spots.sci. gamspar in degrees."""
    g = np.radians(gamspar)
    return np.array([[aspar, bspar * np.cos(g), 0.0],
                     [0.0, bspar * np.sin(g), 0.0],
                     [asperp, bsperp, csperp]])


def surface_reciprocal_cell(lattice, plane):
    """Real-space lattice + parallel plane + s-factor -> reciprocal surface
    cell (aspar, bspar, gamspar [deg], asperp, bsperp, csperp), as in set_sgel.sci."""
    H, K, L, s = plane
    M = reciprocal_matrix(*lattice)
    R = rotation_to_z(M @ np.array([H, K, L], dtype=float))
    Ms = np.diag([1.0, 1.0, 1.0 / s]) @ R @ M
    A, B, C = Ms[:, 0], Ms[:, 1], Ms[:, 2]
    aspar, bspar = np.hypot(A[0], A[1]), np.hypot(B[0], B[1])
    gamspar = np.degrees(np.arccos(np.clip(
        (A[0] * B[0] + A[1] * B[1]) / (aspar * bspar), -1.0, 1.0)))
    return aspar, bspar, gamspar, A[2], B[2], C[2]


def real_lattice(aspar, bspar, gamspar, asperp, bsperp, csperp):
    """Reciprocal surface cell -> real-space (a, b, c, alf, bet, gam) in nm
    and degrees (inverse of surface_reciprocal_cell)."""
    Ms = surface_matrix(aspar, bspar, gamspar, asperp, bsperp, csperp)
    if abs(np.linalg.det(Ms)) < 1e-12:
        raise ValueError("The reciprocal surface cell is degenerate.")
    Rm = 2 * np.pi * np.linalg.inv(Ms).T      # columns: a, b, c vectors
    a, b, c = np.linalg.norm(Rm, axis=0)

    def angle(u, v):
        return np.degrees(np.arccos(np.clip(
            u @ v / (np.linalg.norm(u) * np.linalg.norm(v)), -1.0, 1.0)))
    return (a, b, c, angle(Rm[:, 1], Rm[:, 2]), angle(Rm[:, 0], Rm[:, 2]),
            angle(Rm[:, 0], Rm[:, 1]))


def sg214(h, k, l):
    """Space group 214 (I4_132), single gyroid: allowed reflections."""
    h, k, l = np.abs(h), np.abs(k), np.abs(l)
    rule = (h + k + l) % 2 == 0                    # body centred
    # 4-fold screws along a, b, c: h00: h = 4n, etc.
    rule &= (k != 0) | (l != 0) | (h % 4 == 0)
    rule &= (l != 0) | (h != 0) | (k % 4 == 0)
    rule &= (h != 0) | (k != 0) | (l % 4 == 0)
    return rule


def sg230(h, k, l):
    """Space group 230 (Ia-3d), double gyroid: allowed reflections."""
    h, k, l = np.abs(h), np.abs(k), np.abs(l)
    rule = (h + k + l) % 2 == 0                    # body centred
    # 4-fold screws along a, b, c: h00: h = 4n, etc.
    rule &= (k != 0) | (l != 0) | (h % 4 == 0)
    rule &= (l != 0) | (h != 0) | (k % 4 == 0)
    rule &= (h != 0) | (k != 0) | (l % 4 == 0)
    # diamond glides: hhl: 2h + l = 4n, and the same for the (lkl), (hkk) families
    rule &= (k != l) | ((2 * k + h) % 4 == 0)
    rule &= (l != h) | ((2 * l + k) % 4 == 0)
    rule &= (h != k) | ((2 * h + l) % 4 == 0)
    # other glides: 0kl: k, l = 2n
    rule &= (h != 0) | ((k % 2 == 0) & (l % 2 == 0))
    rule &= (k != 0) | ((l % 2 == 0) & (h % 2 == 0))
    rule &= (l != 0) | ((h % 2 == 0) & (k % 2 == 0))
    return rule


def find_hkl(rule, hmax, kmax, lmax, screw=(1, 1, 1),
             glide=("none", "none", "none")):
    """Port of find_hkl.sci: all space-group allowed (h, k, l) as 3 x N array.

    rule:  P, A, B, C, I, F (Bravais) or sc, bcc, fcc, hcp, dia, cyl, lam
    screw: screw-axis orders along [100], [010], [001] (1 = none)
    glide: glide planes perpendicular to a, b, c; one of
           a: none, a/b, a/c, a/n   b: none, b/c, b/a, b/n
           c: none, c/a, c/b, c/n   (Bravais lattices only)
    """
    h, k, l = np.meshgrid(np.arange(-hmax, hmax + 1),
                          np.arange(-kmax, kmax + 1),
                          np.arange(-lmax, lmax + 1), indexing="ij")
    h, k, l = h.ravel(), k.ravel(), l.ravel()

    def all_same_parity():          # F rule: h+k, k+l, l+h all even
        return ((h + k) % 2 == 0) & ((k + l) % 2 == 0) & ((l + h) % 2 == 0)

    if rule in ("P", "sc", "cyl", "lam"):
        ok = np.ones(h.shape, dtype=bool)
    elif rule == "C":
        ok = (h + k) % 2 == 0
    elif rule == "A":
        ok = (k + l) % 2 == 0
    elif rule == "B":
        ok = (l + h) % 2 == 0
    elif rule in ("F", "fcc"):
        ok = all_same_parity()
    elif rule in ("I", "bcc"):
        ok = (h + k + l) % 2 == 0
    elif rule == "hcp":
        ok = ~(((h + 2 * k) % 3 == 0) & (l % 2 == 1))
    elif rule == "dia":
        # as in find_hkl.sci: same parity and h+k+l = 4n
        ok = all_same_parity() & ((h + k + l) % 4 == 0)
    elif rule == "sgl gyr":
        ok = sg214(h, k, l)
    elif rule == "dbl gyr":
        ok = sg230(h, k, l)
    else:
        raise ValueError("Unknown index rule: " + str(rule))

    # Screw axes and glide planes: only for the Bravais lattices
    if rule in ("P", "A", "B", "C", "I", "F"):
        a_scr, b_scr, c_scr = screw
        if a_scr > 1:
            ok &= (k != 0) | (l != 0) | (h % a_scr == 0)
        if b_scr > 1:
            ok &= (l != 0) | (h != 0) | (k % b_scr == 0)
        if c_scr > 1:
            ok &= (h != 0) | (k != 0) | (l % c_scr == 0)

        a_gl, b_gl, c_gl = glide
        if a_gl == "a/b":
            ok &= (h != 0) | (k % 2 == 0)
        elif a_gl == "a/c":
            ok &= (h != 0) | (l % 2 == 0)
        elif a_gl == "a/n":
            ok &= (h != 0) | ((k + l) % 2 == 0)
        if b_gl == "b/c":
            ok &= (k != 0) | (l % 2 == 0)
        elif b_gl == "b/a":
            ok &= (k != 0) | (h % 2 == 0)
        elif b_gl == "b/n":
            ok &= (k != 0) | ((l + h) % 2 == 0)
        if c_gl == "c/a":
            ok &= (l != 0) | (h % 2 == 0)
        elif c_gl == "c/b":
            ok &= (l != 0) | (k % 2 == 0)
        elif c_gl == "c/n":
            ok &= (l != 0) | ((h + k) % 2 == 0)

    return np.vstack([h[ok], k[ok], l[ok]])


def calc_spots(lattice, rule, plane, angles, setup, sg=None):
    """Python port of calc_spots.sci (indexGIXS, area-detector branch).

    lattice: (a, b, c, alf, bet, gam)    nm and degrees
    rule:    'P', 'A', 'B', 'C', 'I' or 'F'
    plane:   (H, K, L, s)                texture plane and s-factor
    angles:  (alf_i, alf_cF, alf_cS)     degrees
    setup:   (lambda, L_SD, x0, z0, pixel)  nm, mm, pixels, pixels, um
    sg:      index-rule settings, see DEFAULT_SG (None = defaults)

    Spot positions are returned as pixel offsets from the direct beam:
    dx (to the right) and dz (upwards).  Result keys: 'spots' (direct-beam
    scattering), 'rspots' (reflected-beam "double vision", or None), 'lines'
    (horizon / Yoneda lines as dz), 'beams' (direct and reflected beam), 'x0',
    'z0'.  Each spot set is a dict with 'dx', 'dz' and 'hkl' (3 x N).
    """
    H, K, L, s = plane
    alpha_i, alpha_cF, alpha_cS = angles
    lam, l_sd, x0, z0, pixel = setup

    sg = dict(DEFAULT_SG, **(sg or {}))
    side = sg["side"]
    if lam <= 0 or l_sd <= 0 or pixel <= 0:
        raise ValueError("lambda, L_SD and pixel size must be > 0.")

    k0 = 2 * np.pi / lam                      # vacuum wave number, 1/nm
    dist_pix = l_sd * 1000.0 / pixel          # sample-detector distance, pixels

    if sg["search"] == "rec":
        # Reciprocal surface cell is given directly (no rotation, no s-factor)
        Mr = surface_matrix(*lattice)
        s = 1.0
    else:
        if H == 0 and K == 0 and L == 0:
            raise ValueError("H, K, L must not all be zero.")
        if s <= 0:
            raise ValueError("The s-factor must be > 0.")
        # Reciprocal lattice vectors, rotated so that G(HKL) is along the normal
        M = reciprocal_matrix(*lattice)
        R = rotation_to_z(M @ np.array([H, K, L], dtype=float))
        Mr = R @ M

    # All space-group allowed reflections (like calc_spots.sci, (0,0,0) is kept:
    # it marks the reflected beam in the double-vision branch)
    hkl_all = find_hkl(rule, sg["hmax"], sg["kmax"], sg["lmax"],
                       sg["screw"], sg["glide"])
    q = Mr @ hkl_all
    Q = np.hypot(q[0], q[1])          # in-plane component of q
    qz = q[2] / s                     # s-factor: vertical swelling / shrinkage

    # Angles in radians
    al = np.radians(alpha_i)
    cF = np.radians(alpha_cF)
    cS = np.radians(alpha_cS)

    # "Double vision": reflected-beam scattering for alf_cF < alf_i < alf_cS
    refl_flag = alpha_cF < alpha_i < alpha_cS

    # Refracted incident beam inside the film (Busch et al. 2006); as in
    # calc_spots.sci this quantity is used directly as an angle
    alf_i2 = np.sqrt(max(np.sin(al)**2 - np.sin(cF)**2, 0.0))

    def one_branch(refl):
        """refl = -1: direct-beam scattering, +1: reflected-beam branch."""
        # Exit angle inside the film; only reflections above the horizon
        arg = qz / k0 + refl * np.sin(alf_i2)
        ok = (arg >= 0.0) & (arg <= 1.0) & (Q <= 2 * k0)
        bet_f2 = np.arcsin(np.clip(arg, 0.0, 1.0))
        ok &= np.cos(bet_f2) > 1e-9

        # Exit angle outside the film (refraction)
        bet_f = np.arcsin(np.clip(np.sqrt(np.sin(bet_f2)**2 + np.sin(cF)**2),
                                  0.0, 1.0))

        # In-plane scattering angle from the in-plane Bragg angle of the rod.
        # Like real(acos(.)) in Scilab: values just above 1 (Bragg's law not
        # fulfilled, diffuse halo close to the beam stop) give psi = 0.
        with np.errstate(divide="ignore", invalid="ignore"):
            cos_psi = (np.cos(alf_i2)**2 + np.cos(bet_f2)**2 - (Q / k0)**2) / (
                2 * np.cos(alf_i2) * np.cos(bet_f2))
        ok &= cos_psi >= -1.0
        psi = np.arccos(np.clip(np.nan_to_num(cos_psi, nan=2.0), -1.0, 1.0))

        # Transformation to diffractometer angles (exact formula of the paper)
        delta = np.arcsin(np.clip(
            np.sin(al) * np.cos(psi) * np.cos(bet_f) + np.cos(al) * np.sin(bet_f),
            -1.0, 1.0))
        nu = np.arctan2(
            np.sin(psi) * np.cos(bet_f),
            np.cos(al) * np.cos(psi) * np.cos(bet_f) - np.sin(al) * np.sin(bet_f))

        ok &= np.cos(nu) > 1e-6           # must hit the detector plane
        delta, nu = delta[ok], nu[ok]
        hkl = hkl_all[:, ok]
        q_par, q_perp = Q[ok], qz[ok]

        # Pixel offsets from the direct beam
        dz = dist_pix * np.tan(delta) / np.cos(nu)
        dx = dist_pix * np.tan(nu)

        # Left and / or right of the incident plane (dx = 0 only once)
        index, sign = [], []
        if side in ("L", "B"):
            index.append(np.arange(dx.size))
            sign.append(-np.ones(dx.size))
        if side in ("R", "B"):
            right = np.where(dx > 1e-9)[0] if side == "B" else np.arange(dx.size)
            index.append(right)
            sign.append(np.ones(right.size))
        index = np.concatenate(index)
        sign = np.concatenate(sign)

        # Sorted by |q| like in calc_spots.sci
        q_tot = np.hypot(q_par, q_perp)
        order = np.argsort(q_tot[index], kind="stable")
        index, sign = index[order], sign[order]
        return {"dx": sign * dx[index], "dz": dz[index], "hkl": hkl[:, index],
                "nu": np.degrees(nu)[index], "delta": np.degrees(delta)[index],
                "Q": q_par[index], "qz": q_perp[index], "q": q_tot[index]}

    spots = one_branch(-1)
    rspots = one_branch(+1) if refl_flag else None

    # Horizon, Yoneda lines and beam positions (offsets above the direct beam)
    lines = {"horizon": dist_pix * np.tan(al)}
    if alpha_cF > 0:
        lines["film"] = dist_pix * np.tan(al + cF)
    if alpha_cS > 0:
        lines["substrate"] = dist_pix * np.tan(al + cS)
    beams = [0.0, dist_pix * np.tan(2 * al)]     # direct and reflected beam

    return {"spots": spots, "rspots": rspots, "lines": lines, "beams": beams,
            "x0": x0, "z0": z0}


# =============================================================================
# The application
# =============================================================================
class ImageViewerApp:
    # Each input section: (field label, preset value). Empty string = no preset.
    LATTICE_FIELDS = [
        ("a (nm)", "0.383"),
        ("b (nm)", "1.206"),
        ("c (nm)", "1.294"),
        ("alf (deg)", "90.05"),
        ("bet (deg)", "91.98"),
        ("gam (deg)", "95.65"),
    ]
    INDEX_RULES = ["P", "A", "B", "C", "I", "F", "sc", "fcc", "bcc", "hcp",
                   "dia", "sgl gyr", "dbl gyr", "cyl", "lam"]

    PLANE_FIELDS = [
        ("H", "1"),
        ("K", "-2"),
        ("L", "1"),
        ("s-factor", "1"),
    ]

    ANGLE_FIELDS = [
        ("alf_i (deg)", "0.15"),
        ("alf_cF (deg)", "0.15"),
        ("alf_cS (deg)", "0.18"),
    ]

    SETUP_FIELDS = [
        ("lambda (nm)", "0.1162"),
        ("L_SD (mm)", "168.2"),
        ("x0 (pixels)", "448.32"),
        ("z0 (pixels)", "33.45"),
        ("pixel (um)", "172"),     # detector pixel size; 172 um = Pilatus
    ]

    def __init__(self, root):
        self.root = root
        self.root.title("indexGIXS")
        self.root.geometry("{0}x{0}".format(WIN_SIZE))

        self.photo = None        # keep a reference so tkinter doesn't discard it
        self.data = None         # displayed (resized) linear intensity data
        self.name = ""
        self.orig_size = (0, 0)
        self.vmin = None         # intensity range currently displayed
        self.vmax = None
        self.spots = None        # result of calc_spots (original pixel coords)
        self.sg_settings = dict(DEFAULT_SG)   # index-rule menu settings
        self.show_indices = False  # index button: label spots with (h k l)
        self.style = copy.deepcopy(DEFAULT_STYLE)   # spot menu settings
        self.section_labels = {}  # label widgets of each right-hand section

        # Image area: 700 x 700 top left, background = window background
        bg = self.root.cget("bg")
        self.canvas = tk.Canvas(self.root, width=VIEW_SIZE, height=VIEW_SIZE,
                                bg=bg, highlightthickness=0)
        self.canvas.grid(row=0, column=0, sticky="nw")

        # Colour bar below the image: log intensity scale of the displayed range
        self.cbar_canvas = tk.Canvas(self.root, width=VIEW_SIZE,
                                     height=CBAR_AREA_H, bg=bg,
                                     highlightthickness=0)
        self.cbar_canvas.grid(row=1, column=0, sticky="nw")
        self.cbar_photo = None
        self.update_colorbar()

        # One row below the colour bar: Load button at the far left, the
        # intensity range fields right next to it
        self.controls = tk.Frame(self.root)
        self.controls.grid(row=2, column=0, sticky="w", padx=(6, 0), pady=(6, 4))

        self.load_button = tk.Button(self.controls, text="Load", width=10,
                                     font=("Arial", 12, "bold"), bg=LOAD_BG,
                                     activebackground="#28a428",
                                     command=self.load_image)
        self.load_button.pack(side=tk.LEFT)

        # Label and input fields for min / max intensity
        self.range_frame = tk.Frame(self.controls)
        self.range_frame.pack(side=tk.LEFT, padx=(28, 0))

        self.range_label = tk.Label(self.range_frame, text="Intensity range:",
                                    font=("Arial", 12))
        self.range_label.pack(side=tk.LEFT, padx=(0, 8))

        tk.Label(self.range_frame, text="min", font=("Arial", 12)).pack(
            side=tk.LEFT)
        self.min_var = tk.StringVar()
        self.min_entry = tk.Entry(self.range_frame, textvariable=self.min_var,
                                  width=12, font=("Arial", 12),
                                  state=tk.DISABLED)
        self.min_entry.pack(side=tk.LEFT, padx=(4, 12))

        tk.Label(self.range_frame, text="max", font=("Arial", 12)).pack(
            side=tk.LEFT)
        self.max_var = tk.StringVar()
        self.max_entry = tk.Entry(self.range_frame, textvariable=self.max_var,
                                  width=12, font=("Arial", 12),
                                  state=tk.DISABLED)
        self.max_entry.pack(side=tk.LEFT, padx=4)

        # Apply on Enter or when the field loses focus
        for entry in (self.min_entry, self.max_entry):
            entry.bind("<Return>", self.apply_range)
            entry.bind("<KP_Enter>", self.apply_range)
            entry.bind("<FocusOut>", self.apply_range)

        # Status line
        self.status = tk.Label(self.root, text="No image loaded",
                               font=("Arial", 10), anchor="w")
        self.status.grid(row=3, column=0, sticky="nw", padx=6, pady=(0, 4))

        # Right-hand side: all input sections, stacked from the top
        self.build_right_panel()

    # --- Right-hand panel (column 1, from the top) ---
    def build_right_panel(self):
        self.right_frame = tk.Frame(self.root)
        self.right_frame.grid(row=0, column=1, rowspan=2, sticky="nw",
                              padx=15, pady=5)

        # Lattice params (plus the index rule pull-down below the fields)
        self.lattice_vars, next_row = self.add_section(
            "Lattice parameters", self.LATTICE_FIELDS, start_row=0)

        self.rule_button = tk.Button(
            self.right_frame, text="Index rule", width=11,
            font=("Arial", 12, "bold"), bg=RULE_BG, activebackground="#c79ceb",
            command=self.open_index_rule_dialog)
        self.rule_button.grid(row=next_row, column=0, sticky="w", pady=2)
        self.index_rule_var = tk.StringVar(value=self.INDEX_RULES[0])
        self.index_rule_box = ttk.Combobox(
            self.right_frame, textvariable=self.index_rule_var,
            values=self.INDEX_RULES, width=10, state="readonly",
            font=("Arial", 12))
        self.index_rule_box.grid(row=next_row, column=1, sticky="w",
                                 padx=(10, 0), pady=2)
        # Choosing a predefined lattice presets cell and close-packed plane
        self.index_rule_box.bind("<<ComboboxSelected>>", self.set_lattice)
        next_row += 1

        # Parallel plane
        self.plane_vars, next_row = self.add_section(
            "Parallel plane", self.PLANE_FIELDS, start_row=next_row)

        # Angles
        self.angle_vars, next_row = self.add_section(
            "Angles", self.ANGLE_FIELDS, start_row=next_row)

        # Setup
        self.setup_vars, next_row = self.add_section(
            "Setup", self.SETUP_FIELDS, start_row=next_row)

        # Calc and Index buttons: bottom of the colour bar row, directly above
        # the Spot and Edit buttons
        top = tk.Frame(self.root)
        top.grid(row=1, column=1, sticky="sw", padx=15, pady=(0, 3))
        self.calc_button = tk.Button(top, text="Calc", width=8,
                                     font=("Arial", 12, "bold"), bg="orange",
                                     activebackground="dark orange",
                                     command=self.calc)
        self.calc_button.pack(side=tk.LEFT)
        self.index_button = tk.Button(top, text="Index", width=8,
                                      font=("Arial", 12, "bold"), bg="orange",
                                      activebackground="dark orange",
                                      command=self.toggle_indices)
        self.index_button.pack(side=tk.LEFT, padx=(8, 0))

        # Spot and Edit buttons: same grid row as the Load button, so that the
        # two lines of controls are level; same left edge as Calc and Index
        bottom = tk.Frame(self.root)
        bottom.grid(row=2, column=1, sticky="w", padx=15, pady=(6, 4))
        self.spot_button = tk.Button(bottom, text="Spot", width=8,
                                     font=("Arial", 12, "bold"), bg="orange",
                                     activebackground="dark orange",
                                     command=self.open_spot_dialog)
        self.spot_button.pack(side=tk.LEFT)
        self.edit_button = tk.Button(bottom, text="Edit", width=8,
                                     font=("Arial", 12, "bold"), bg="orange",
                                     activebackground="dark orange",
                                     command=self.open_edit_dialog)
        self.edit_button.pack(side=tk.LEFT, padx=(8, 0))

        # Number of spots: same grid row as the file name status line
        self.calc_info = tk.Label(self.root, text="", anchor="w", justify="left",
                                  wraplength=240, font=("Arial", 10))
        self.calc_info.grid(row=3, column=1, sticky="nw", padx=15, pady=(0, 4))

    def add_section(self, title, fields, start_row):
        """Add a bold title followed by one row per field (label on the
        left, input box on the right). Returns a dict {label: StringVar}
        and the next free grid row."""
        top_gap = 0 if start_row == 0 else 14
        tk.Label(self.right_frame, text=title,
                 font=("Arial", 13, "bold")).grid(
            row=start_row, column=0, columnspan=2, sticky="w",
            pady=(top_gap, 4))

        variables = {}
        labels = []
        row = start_row + 1
        for text, default in fields:
            label = tk.Label(self.right_frame, text=text, font=("Arial", 12),
                             anchor="w")
            label.grid(row=row, column=0, sticky="w", pady=2)
            labels.append(label)
            var = tk.StringVar(value=default)
            tk.Entry(self.right_frame, textvariable=var, width=12,
                     font=("Arial", 12)).grid(row=row, column=1, sticky="w",
                                              padx=(10, 0), pady=2)
            variables[text] = var
            row += 1
        self.section_labels[title] = labels
        return variables, row

    @staticmethod
    def read_values(variables):
        """Return the values of a {label: StringVar} dict as a tuple of
        floats, or None if any field is empty or not a valid number."""
        values = []
        for var in variables.values():
            try:
                values.append(float(var.get().replace(",", ".")))
            except ValueError:
                return None
        return tuple(values)

    def get_lattice_params(self):
        """(a, b, c, alf, bet, gam) or None."""
        return self.read_values(self.lattice_vars)

    def get_plane(self):
        """(H, K, L, s-factor) or None."""
        return self.read_values(self.plane_vars)

    def get_angles(self):
        """(alf_i, alf_cF, alf_cS) or None. alf_cF and alf_cS may be left
        empty (taken as 0 = no refraction correction / line not drawn)."""
        values = []
        for i, var in enumerate(self.angle_vars.values()):
            text = var.get().strip().replace(",", ".")
            if text == "" and i > 0:
                values.append(0.0)
                continue
            try:
                values.append(float(text))
            except ValueError:
                return None
        return tuple(values)

    def get_setup(self):
        """(lambda, L_SD, x0, z0, pixel) or None."""
        return self.read_values(self.setup_vars)

    # --- Predefined lattices (port of set_lattice.sci) ---
    # rule: (b, c, gamma, (H, K, L)); b, c: "a" = same as a, "hcp" = ideal
    # hcp c/a, or a fixed number in nm. alf = bet = 90, s-factor = 1.
    LATTICE_PRESETS = {
        "sc":      ("a", "a", 90, (0, 0, 1)),
        "bcc":     ("a", "a", 90, (1, 1, 0)),
        "fcc":     ("a", "a", 90, (1, 1, 1)),
        "hcp":     ("a", "hcp", 120, (0, 0, 1)),
        "dia":     ("a", "a", 90, (1, 1, 1)),
        "sgl gyr": ("a", "a", 90, (1, 1, 0)),
        "dbl gyr": ("a", "a", 90, (1, 1, 2)),
        "cyl":     ("a", 0.01, 120, (1, 0, 0)),
        "lam":     (0.01, 0.01, 90, (1, 0, 0)),
    }

    def set_lattice(self, event=None):
        """Called when a rule is chosen in the pulldown: sets b, c and the
        angles from a, and the close-packed plane (the Bravais letters
        P, A, B, C, I, F have no presets)."""
        preset = self.LATTICE_PRESETS.get(self.index_rule_var.get())
        if preset is None or self.sg_settings["search"] == "rec":
            return
        b_spec, c_spec, gamma, hkl = preset

        a_vars = list(self.lattice_vars.values())     # a, b, c, alf, bet, gam
        a_text = a_vars[0].get().strip().replace(",", ".")
        try:
            a = float(a_text)
        except ValueError:
            a = None

        def value(spec):
            if spec == "a":
                return a_text
            if spec == "hcp":
                return str(float(np.trunc(a * np.sqrt(8.0 / 3.0) * 100)) / 100)
            return str(spec)

        if a is None and "a" in (b_spec, c_spec) or (a is None and c_spec == "hcp"):
            messagebox.showinfo(
                "lattice", "Enter the lattice parameter a (nm), then select "
                "the lattice again to set b, c and the close-packed plane.")
        else:
            a_vars[1].set(value(b_spec))
            a_vars[2].set(value(c_spec))
        a_vars[3].set("90")
        a_vars[4].set("90")
        a_vars[5].set(str(gamma))

        # close-packed plane and s-factor
        for var, val in zip(self.plane_vars.values(), (*hkl, 1)):
            var.set(str(val))

    # --- Index rule / space group elements menu (port of set_sgel.sci) ---
    SCREW_CHOICES = ["1", "2", "3", "4", "6"]
    GLIDE_CHOICES = (["none", "a/b", "a/c", "a/n"],
                     ["none", "b/c", "b/a", "b/n"],
                     ["none", "c/a", "c/b", "c/n"])
    REC_LABELS = ["aspar (1/nm)", "bspar (1/nm)", "gamspar (deg)",
                  "asperp (1/nm)", "bsperp (1/nm)", "csperp (1/nm)"]

    def sg_is_default(self):
        sg = self.sg_settings
        return (tuple(sg["screw"]) == (1, 1, 1)
                and tuple(sg["glide"]) == ("none", "none", "none"))

    def update_rule_button(self):
        """Red 'SG elements' text if a screw axis or glide plane is set."""
        if self.sg_is_default():
            self.rule_button.config(text="Index rule", fg="black")
        else:
            self.rule_button.config(text="SG elements", fg="#b30000")

    def open_index_rule_dialog(self):
        sg = self.sg_settings
        dlg = tk.Toplevel(self.root)
        dlg.title("index rules")
        dlg.transient(self.root)
        dlg.resizable(False, False)
        body = tk.Frame(dlg, padx=14, pady=10)
        body.pack()

        entries = {}
        row = [0]

        def heading(text):
            tk.Label(body, text=text, font=("Arial", 12, "bold")).grid(
                row=row[0], column=0, columnspan=2, sticky="w", pady=(10, 2))
            row[0] += 1

        def add(key, label, widget_factory, value):
            tk.Label(body, text=label, font=("Arial", 12)).grid(
                row=row[0], column=0, sticky="w", pady=2)
            var = tk.StringVar(value=str(value))
            widget_factory(body, var).grid(row=row[0], column=1, sticky="w",
                                           padx=(12, 0), pady=2)
            entries[key] = var
            row[0] += 1

        def combo(values):
            return lambda parent, var: ttk.Combobox(
                parent, textvariable=var, values=values, width=8,
                state="readonly", font=("Arial", 12))

        def spin(parent, var):
            return tk.Spinbox(parent, from_=0, to=20, width=8, textvariable=var,
                              font=("Arial", 12))

        heading("screw axes")
        for i, axis in enumerate("abc"):
            add("screw" + axis, axis + ": 1, 2, 3, 4, 6",
                combo(self.SCREW_CHOICES), sg["screw"][i])
        heading("glide planes")
        for i, axis in enumerate("abc"):
            add("glide" + axis, "perpendicular to " + axis,
                combo(self.GLIDE_CHOICES[i]), sg["glide"][i])
        heading("index range")
        add("hmax", "Hmax", spin, sg["hmax"])
        add("kmax", "Kmax", spin, sg["kmax"])
        add("lmax", "Lmax", spin, sg["lmax"])
        add("side", "Mode (L/R/B)", combo(["L", "R", "B"]), sg["side"])
        heading("search space")
        add("search", "real/reciprocal (real/rec)", combo(["real", "rec"]),
            sg["search"])

        result = []

        def on_ok():
            try:
                limits = [int(entries[k].get()) for k in ("hmax", "kmax", "lmax")]
            except ValueError:
                messagebox.showerror("index rules",
                                     "Hmax, Kmax and Lmax must be integers.",
                                     parent=dlg)
                return
            if min(limits) < 0 or max(limits) > 20:
                messagebox.showerror("index rules",
                                     "Hmax, Kmax and Lmax must be between 0 and 20.",
                                     parent=dlg)
                return
            result.append({
                "hmax": limits[0], "kmax": limits[1], "lmax": limits[2],
                "screw": tuple(int(entries["screw" + a].get()) for a in "abc"),
                "glide": tuple(entries["glide" + a].get() for a in "abc"),
                "side": entries["side"].get(),
                "search": entries["search"].get()})
            dlg.destroy()

        buttons = tk.Frame(dlg, pady=10)
        buttons.pack()
        tk.Button(buttons, text="OK", width=10, font=("Arial", 12),
                  command=on_ok).pack(side=tk.LEFT, padx=6)
        tk.Button(buttons, text="Cancel", width=10, font=("Arial", 12),
                  command=dlg.destroy).pack(side=tk.LEFT, padx=6)

        dlg.grab_set()
        self.root.wait_window(dlg)

        if result:                       # OK pressed
            previous = self.sg_settings["search"]
            self.sg_settings = result[0]
            if self.sg_settings["search"] != previous:
                if not self.switch_search_mode(self.sg_settings["search"]):
                    self.sg_settings["search"] = previous
            self.update_rule_button()

    def set_lattice_values(self, values):
        for var, value in zip(self.lattice_vars.values(), values):
            var.set(str(float(round(value * 100) / 100)))

    def set_lattice_labels(self, texts):
        for label, text in zip(self.section_labels["Lattice params"], texts):
            label.config(text=text)

    def switch_search_mode(self, target):
        """Convert the lattice fields between the real-space cell and the
        reciprocal surface cell. Returns False if the switch was refused."""
        lattice = self.get_lattice_params()
        if lattice is None:
            messagebox.showerror("index rules",
                                 "Enter valid numbers in the lattice fields first.")
            return False

        try:
            if target == "rec":
                plane = self.get_plane()
                if plane is None or tuple(plane[:3]) != (0.0, 0.0, 1.0):
                    messagebox.showinfo(
                        "index rules",
                        "Switch to reciprocal lattice only for HKL = 001.")
                    return False
                self.set_lattice_values(surface_reciprocal_cell(lattice, plane))
                self.set_lattice_labels(self.REC_LABELS)
            else:
                self.set_lattice_values(real_lattice(*lattice))
                # surface unit cell from now on
                for var, value in zip(self.plane_vars.values(),
                                      ("0", "0", "1", "1")):
                    var.set(value)
                self.set_lattice_labels([t for t, _ in self.LATTICE_FIELDS])
        except ValueError as err:
            messagebox.showerror("index rules", str(err))
            return False
        return True

    # --- Reflection calculation (calc button) ---
    def calc(self):
        if self.data is None:
            messagebox.showinfo("calc", "Load an image first.")
            return

        lattice = self.get_lattice_params()
        plane = self.get_plane()
        angles = self.get_angles()
        setup = self.get_setup()
        problems = []
        if lattice is None:
            problems.append("Lattice params (a, b, c, alf, bet, gam)")
        if plane is None:
            problems.append("Parallel plane (H, K, L, s-factor)")
        if angles is None:
            problems.append("alf_i (alf_cF and alf_cS may stay empty)")
        if setup is None:
            problems.append("Setup (lambda, L_SD, x0, z0, pixel)")
        if problems:
            messagebox.showerror(
                "Missing input",
                "Please enter valid numbers for:\n\n" + "\n".join(problems))
            return

        try:
            self.spots = calc_spots(lattice, self.index_rule_var.get(),
                                    plane, angles, setup,
                                    self.sg_settings)
        except ValueError as err:
            messagebox.showerror("Calculation failed", str(err))
            return

        self.draw_overlay()
        text = "{} reflections".format(self.spots["spots"]["dx"].size)
        if self.spots["rspots"] is not None:
            text += " + {} reflected-beam".format(
                self.spots["rspots"]["dx"].size)
        self.calc_info.config(text=text)

    def draw_marker(self, cx, cy, marker):
        """Draw one symbol (circ, squ, up, down, dia, +, x, *) at (cx, cy)."""
        symbol = marker["symbol"]
        r = float(marker["size"]) / 2.0
        rim = decode_colour(marker["rim"])
        fill = decode_colour(marker["fill"])
        c = self.canvas
        shape = dict(outline=rim, fill=fill, width=2, tags="overlay")
        if symbol == "circ":
            c.create_oval(cx - r, cy - r, cx + r, cy + r, **shape)
        elif symbol == "squ":
            c.create_rectangle(cx - r, cy - r, cx + r, cy + r, **shape)
        elif symbol == "up":
            c.create_polygon(cx, cy - r, cx + r, cy + r, cx - r, cy + r, **shape)
        elif symbol == "down":
            c.create_polygon(cx, cy + r, cx + r, cy - r, cx - r, cy - r, **shape)
        elif symbol == "dia":
            c.create_polygon(cx, cy - r, cx + r, cy, cx, cy + r, cx - r, cy,
                             **shape)
        elif symbol in ("+", "x", "*") and rim:
            arms = {"+": [(0, 1), (1, 0)],
                    "x": [(0.7071, 0.7071), (0.7071, -0.7071)],
                    "*": [(0, 1), (0.866, 0.5), (0.866, -0.5)]}[symbol]
            for ux, uy in arms:
                c.create_line(cx - ux * r, cy - uy * r, cx + ux * r, cy + uy * r,
                              fill=rim, width=2, tags="overlay")

    def draw_overlay(self):
        """Draw the calculated spots and lines on top of the image."""
        self.canvas.delete("overlay")
        if self.spots is None or self.data is None:
            return
        st = self.style

        # Map original detector pixels to canvas coordinates
        new_h, new_w = self.data.shape
        w, h = self.orig_size
        sx, sy = new_w / w, new_h / h
        off_x = VIEW_SIZE // 2 - new_w / 2.0
        off_y = VIEW_SIZE // 2 - new_h / 2.0

        x0 = self.spots["x0"]
        z0 = self.spots["z0"]
        row0 = (h - z0) if Z_FROM_BOTTOM else z0     # beam row, counted from top

        def to_canvas(dx, dz):
            """Pixel offsets from the direct beam -> canvas coordinates."""
            return (off_x + (x0 + dx) * sx, off_y + (row0 - dz) * sy)

        def inside(cx, cy):
            return off_x <= cx <= off_x + new_w and off_y <= cy <= off_y + new_h

        # Horizon, film Yoneda and substrate Yoneda lines
        for name, key in (("horizon", "horizon"), ("film", "yonedaF"),
                          ("substrate", "yonedaS")):
            line = st[key]
            if name not in self.spots["lines"] or line["style"] == "none":
                continue
            y = to_canvas(0.0, self.spots["lines"][name])[1]
            if off_y <= y <= off_y + new_h:
                self.canvas.create_line(
                    off_x, y, off_x + new_w, y, fill=decode_colour(line["color"]),
                    dash=LINE_DASH[line["style"]], width=int(line["width"]),
                    tags="overlay")

        # Direct-beam spots and reflected-beam spots
        labels = []                       # (dx, dz, h, k, l) of visible spots

        def markers(spot_set, marker):
            hkl = spot_set["hkl"]
            for i, (dx, dz) in enumerate(zip(spot_set["dx"], spot_set["dz"])):
                cx, cy = to_canvas(dx, dz)
                if inside(cx, cy):
                    self.draw_marker(cx, cy, marker)
                    labels.append((dx, dz, *hkl[:, i]))

        markers(self.spots["spots"], st["spots"])
        if self.spots["rspots"] is not None:
            markers(self.spots["rspots"], st["rspots"])

        # Diffraction indices next to the spots (index button)
        if self.show_indices:
            if len(labels) > MAX_LABELS:
                self.calc_info.config(
                    text="{} spots in view: too many to label (max {}); "
                         "reduce Hmax, Kmax, Lmax".format(len(labels), MAX_LABELS))
            else:
                text = st["text"]
                font = ("Arial", FONT_PT[int(text["size"])],
                        {"normal": "normal", "italics": "italic",
                         "bold": "bold"}[text["style"]])
                for dx, dz, hh, kk, ll in labels:
                    lx, ly = to_canvas(dx + float(text["offset"]), dz)
                    self.canvas.create_text(
                        lx, ly, anchor="w", fill=decode_colour(text["color"]),
                        text="{} {} {}".format(int(hh), int(kk), int(ll)),
                        font=font, tags="overlay")

        # Direct and reflected beam positions
        if st["beams"]["symbol"] != "none":
            for dz in self.spots["beams"]:
                cx, cy = to_canvas(0.0, dz)
                if inside(cx, cy):
                    self.draw_marker(cx, cy, st["beams"])

    def toggle_indices(self):
        """index button: show / hide the (h k l) labels at the spots."""
        self.show_indices = not self.show_indices
        self.index_button.config(
            relief=tk.SUNKEN if self.show_indices else tk.RAISED)
        self.draw_overlay()

    # --- Spot style menu (port of get_plot_info.sci) ---
    COLOUR_CHOICES = ["blk", "red", "grn", "blu", "cya", "mag", "yel", "wht"]

    def colour_ok(self, text):
        """True for none, the abbreviations, or any colour Tk understands."""
        colour = decode_colour(text)
        if colour == "":
            return True
        try:
            self.root.winfo_rgb(colour)
        except tk.TclError:
            return False
        return True

    def open_spot_dialog(self):
        st = self.style
        dlg = tk.Toplevel(self.root)
        dlg.title("specify plot")
        dlg.transient(self.root)
        dlg.resizable(False, False)
        outer = tk.Frame(dlg, padx=14, pady=10)
        outer.pack()
        left = tk.Frame(outer)
        left.grid(row=0, column=0, sticky="n", padx=(0, 28))
        right = tk.Frame(outer)
        right.grid(row=0, column=1, sticky="n")

        rows = {left: 0, right: 0}
        entries = {}                 # (section, field) -> StringVar

        def heading(parent, text):
            tk.Label(parent, text=text, font=("Arial", 12, "bold")).grid(
                row=rows[parent], column=0, columnspan=2, sticky="w", pady=(8, 2))
            rows[parent] += 1

        def field(parent, key, label, value, choices=None, editable=False,
                  bounds=None):
            tk.Label(parent, text=label, font=("Arial", 11)).grid(
                row=rows[parent], column=0, sticky="w", pady=2)
            var = tk.StringVar(value=str(value))
            if bounds is None:
                widget = ttk.Combobox(
                    parent, textvariable=var, values=choices, width=9,
                    state="normal" if editable else "readonly",
                    font=("Arial", 11))
            else:
                widget = tk.Spinbox(
                    parent, from_=bounds[0], to=bounds[1], increment=bounds[2],
                    width=9, textvariable=var, font=("Arial", 11))
            widget.grid(row=rows[parent], column=1, sticky="w", padx=(10, 0),
                        pady=2)
            entries[key] = var
            rows[parent] += 1

        def colour_field(parent, key, label, value, none_first=False):
            choices = self.COLOUR_CHOICES + ["none"]
            field(parent, key, label, value, choices, editable=True)

        def marker_section(parent, title, section, symbols):
            heading(parent, title)
            field(parent, (section, "symbol"), "symbol", st[section]["symbol"],
                  symbols)
            field(parent, (section, "size"), "size (points)",
                  st[section]["size"], bounds=(1, 40, 1))
            colour_field(parent, (section, "rim"), "rim color",
                         st[section]["rim"])
            colour_field(parent, (section, "fill"), "fill color",
                         st[section]["fill"])

        def line_section(parent, label, section):
            field(parent, (section, "style"), label + " line style",
                  st[section]["style"], LINE_STYLES)
            field(parent, (section, "width"), label + " thickness (1-5)",
                  st[section]["width"], bounds=(1, 5, 1))
            colour_field(parent, (section, "color"), label + " line color",
                         st[section]["color"])

        marker_section(left, "spots", "spots", SYMBOLS)
        marker_section(left, "rspots", "rspots", SYMBOLS)
        heading(left, "text (hkl labels)")
        field(left, ("text", "style"), "style", st["text"]["style"], TEXT_STYLES)
        field(left, ("text", "size"), "size (1-5)", st["text"]["size"],
              bounds=(1, 5, 1))
        colour_field(left, ("text", "color"), "color", st["text"]["color"])
        field(left, ("text", "offset"), "offset (pixels)", st["text"]["offset"],
              bounds=(-200, 200, 1))

        marker_section(right, "direct & reflected beam", "beams",
                       SYMBOLS + ["none"])
        heading(right, "lines")
        line_section(right, "horizon", "horizon")
        line_section(right, "film Yoneda", "yonedaF")
        line_section(right, "sub Yoneda", "yonedaS")
        heading(right, "plot labels")
        field(right, ("cbar", "size"), "colorbar labels (1-5)", st["cbar_size"],
              bounds=(1, 5, 1))

        tk.Label(dlg, text="colors: blk, red, grn, blu, cya, mag, yel, wht, none, "
                           "or any color name / #rrggbb", font=("Arial", 10),
                 fg="#444444").pack(pady=(0, 4))

        def on_ok():
            new = copy.deepcopy(st)
            try:
                for section in ("spots", "rspots", "beams"):
                    new[section]["symbol"] = entries[(section, "symbol")].get()
                    new[section]["size"] = float(entries[(section, "size")].get())
                    if new[section]["size"] <= 0:
                        raise ValueError("Symbol sizes must be greater than 0.")
                    for part in ("rim", "fill"):
                        value = entries[(section, part)].get().strip()
                        if not self.colour_ok(value):
                            raise ValueError("Unknown color: " + value)
                        new[section][part] = value
                new["text"]["style"] = entries[("text", "style")].get()
                new["text"]["size"] = int(float(entries[("text", "size")].get()))
                new["text"]["offset"] = float(
                    entries[("text", "offset")].get().replace(",", "."))
                value = entries[("text", "color")].get().strip()
                if not self.colour_ok(value):
                    raise ValueError("Unknown color: " + value)
                new["text"]["color"] = value
                for section in ("horizon", "yonedaF", "yonedaS"):
                    new[section]["style"] = entries[(section, "style")].get()
                    new[section]["width"] = int(float(
                        entries[(section, "width")].get()))
                    value = entries[(section, "color")].get().strip()
                    if not self.colour_ok(value):
                        raise ValueError("Unknown color: " + value)
                    new[section]["color"] = value
                new["cbar_size"] = int(float(entries[("cbar", "size")].get()))
                for size in (new["text"]["size"], new["cbar_size"]):
                    if size not in FONT_PT:
                        raise ValueError("Text sizes must be between 1 and 5.")
                for section in ("horizon", "yonedaF", "yonedaS"):
                    if not 1 <= new[section]["width"] <= 5:
                        raise ValueError("Line thicknesses must be between 1 and 5.")
            except ValueError as err:
                messagebox.showerror("specify plot", str(err), parent=dlg)
                return
            self.style = new
            dlg.destroy()
            self.draw_overlay()
            self.update_colorbar()

        buttons = tk.Frame(dlg, pady=8)
        buttons.pack()
        tk.Button(buttons, text="OK", width=10, font=("Arial", 12),
                  command=on_ok).pack(side=tk.LEFT, padx=6)
        tk.Button(buttons, text="Cancel", width=10, font=("Arial", 12),
                  command=dlg.destroy).pack(side=tk.LEFT, padx=6)
        dlg.grab_set()

    # --- Spot list editor (port of edit_spots.sci) ---
    EDIT_COLUMNS = ("h", "k", "l", "x", "z", "nu", "del", "Q", "qz", "q")

    def spots_to_rows(self, spot_set):
        """Spot set -> table rows (h, k, l, x, z, nu, del, Q, qz, q)."""
        x0, z0 = self.spots["x0"], self.spots["z0"]
        zsign = 1.0 if Z_FROM_BOTTOM else -1.0
        rows = []
        for i in range(spot_set["dx"].size):
            h, k, l = spot_set["hkl"][:, i]
            rows.append((int(h), int(k), int(l),
                         x0 + spot_set["dx"][i], z0 + zsign * spot_set["dz"][i],
                         spot_set["nu"][i], spot_set["delta"][i],
                         spot_set["Q"][i], spot_set["qz"][i], spot_set["q"][i]))
        return rows

    def rows_to_spots(self, rows):
        """Table rows -> spot set (inverse of spots_to_rows)."""
        x0, z0 = self.spots["x0"], self.spots["z0"]
        zsign = 1.0 if Z_FROM_BOTTOM else -1.0
        arr = np.array(rows, dtype=float).reshape(-1, len(self.EDIT_COLUMNS))
        return {"dx": arr[:, 3] - x0, "dz": (arr[:, 4] - z0) * zsign,
                "hkl": np.rint(arr[:, 0:3]).astype(int).T,
                "nu": arr[:, 5], "delta": arr[:, 6], "Q": arr[:, 7],
                "qz": arr[:, 8], "q": arr[:, 9]}

    def open_edit_dialog(self):
        if self.spots is None:
            messagebox.showinfo("edit", "Run calc first.")
            return

        sets = [("spots", self.spots["spots"])]
        if self.spots["rspots"] is not None:
            sets.append(("rspots", self.spots["rspots"]))

        dlg = tk.Toplevel(self.root)
        dlg.title("edit spots")
        dlg.transient(self.root)
        notebook = ttk.Notebook(dlg)
        notebook.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
        trees = {}

        def fmt(index, value):
            return str(int(value)) if index < 3 else "{:.7g}".format(value)

        def edit_cell(event):
            """Double-click a value to edit it."""
            tree = event.widget
            if tree.identify("region", event.x, event.y) != "cell":
                return
            item = tree.identify_row(event.y)
            column = tree.identify_column(event.x)
            index = int(column[1:]) - 1
            name = self.EDIT_COLUMNS[index]
            box = tree.bbox(item, column)
            if not box:
                return
            entry = tk.Entry(tree, font=("Arial", 10))
            entry.place(x=box[0], y=box[1], width=box[2], height=box[3])
            entry.insert(0, tree.set(item, name))
            entry.select_range(0, tk.END)
            entry.focus_set()

            def commit(_event=None):
                if not entry.winfo_exists():
                    return
                try:
                    number = float(entry.get().strip().replace(",", "."))
                except ValueError:
                    entry.destroy()
                    return
                tree.set(item, name, fmt(index, number))
                entry.destroy()

            entry.bind("<Return>", commit)
            entry.bind("<KP_Enter>", commit)
            entry.bind("<FocusOut>", commit)
            entry.bind("<Escape>", lambda e: entry.destroy())

        for name, spot_set in sets:
            page = tk.Frame(notebook)
            notebook.add(page, text="{} ({})".format(name, spot_set["dx"].size))
            tree = ttk.Treeview(page, columns=self.EDIT_COLUMNS, show="headings",
                                height=18, selectmode="extended")
            for index, column in enumerate(self.EDIT_COLUMNS):
                tree.heading(column, text=column)
                tree.column(column, width=45 if index < 3 else 112, anchor="e")
            scroll = ttk.Scrollbar(page, orient="vertical", command=tree.yview)
            tree.configure(yscrollcommand=scroll.set)
            tree.grid(row=0, column=0, columnspan=5, sticky="nsew")
            scroll.grid(row=0, column=5, sticky="ns")
            for row in self.spots_to_rows(spot_set):
                tree.insert("", "end", values=[fmt(i, v)
                                               for i, v in enumerate(row)])
            tree.bind("<Double-1>", edit_cell)
            trees[name] = tree

            def delete_selected(tree=tree):
                for item in tree.selection():
                    tree.delete(item)

            def keep_selected(tree=tree):
                keep = set(tree.selection())
                if not keep:
                    messagebox.showinfo("edit", "Select the spots to keep first.",
                                        parent=dlg)
                    return
                for item in tree.get_children():
                    if item not in keep:
                        tree.delete(item)

            def save_list(tree=tree, name=name):
                path = filedialog.asksaveasfilename(
                    parent=dlg, defaultextension=".dat", initialfile=name + ".dat",
                    filetypes=[("Data files", "*.dat"), ("All files", "*.*")])
                if not path:
                    return
                with open(path, "w") as handle:
                    handle.write("# " + " ".join(self.EDIT_COLUMNS) + "\n")
                    for item in tree.get_children():
                        handle.write(" ".join(tree.item(item, "values")) + "\n")

            bar = tk.Frame(page)
            bar.grid(row=1, column=0, columnspan=6, sticky="ew", pady=(6, 0))
            tk.Button(bar, text="Delete selected", font=("Arial", 11),
                      command=delete_selected).pack(side=tk.LEFT)
            tk.Button(bar, text="Keep only selected", font=("Arial", 11),
                      command=keep_selected).pack(side=tk.LEFT, padx=(8, 0))
            tk.Button(bar, text="Save...", font=("Arial", 11),
                      command=save_list).pack(side=tk.RIGHT)
            page.columnconfigure(0, weight=1)

        tk.Label(dlg, text="Double-click a value to edit it. OK plots the "
                           "edited list.", font=("Arial", 10),
                 fg="#444444").pack()

        def on_ok():
            try:
                for name, tree in trees.items():
                    rows = [[float(v) for v in tree.item(item, "values")]
                            for item in tree.get_children()]
                    edited = self.rows_to_spots(rows)
                    self.spots["spots" if name == "spots" else "rspots"] = edited
            except ValueError as err:
                messagebox.showerror("edit", str(err), parent=dlg)
                return
            dlg.destroy()
            self.draw_overlay()
            text = "{} reflections".format(self.spots["spots"]["dx"].size)
            if self.spots["rspots"] is not None:
                text += " + {} reflected-beam".format(
                    self.spots["rspots"]["dx"].size)
            self.calc_info.config(text=text + " (edited)")

        buttons = tk.Frame(dlg, pady=8)
        buttons.pack()
        tk.Button(buttons, text="OK", width=10, font=("Arial", 12),
                  command=on_ok).pack(side=tk.LEFT, padx=6)
        tk.Button(buttons, text="Cancel", width=10, font=("Arial", 12),
                  command=dlg.destroy).pack(side=tk.LEFT, padx=6)
        dlg.grab_set()

    # --- Colour bar ---
    def update_colorbar(self):
        """Jet colour bar with a logarithmic scale for the displayed range."""
        c = self.cbar_canvas
        cb_font = ("Arial", FONT_PT[int(self.style["cbar_size"])])
        c.delete("all")
        if self.cbar_photo is None:          # the gradient is built only once
            norm = np.tile(np.linspace(0.0, 1.0, CBAR_W), (CBAR_H, 1))
            rgba = matplotlib.colormaps["jet"](norm, bytes=True)
            self.cbar_photo = ImageTk.PhotoImage(
                Image.fromarray(rgba[..., :3], mode="RGB"))

        x_left = (VIEW_SIZE - CBAR_W) // 2
        top = 14
        bottom = top + CBAR_H
        c.create_image(x_left, top, anchor="nw", image=self.cbar_photo)
        c.create_rectangle(x_left, top, x_left + CBAR_W, bottom, outline="black")
        if self.vmin is None:
            return

        lo, hi = np.log10(self.vmin), np.log10(self.vmax)

        def x_of(value):
            return x_left + (np.log10(value) - lo) / (hi - lo) * CBAR_W

        # Limits of the displayed range at both ends of the bar
        c.create_text(x_left - 6, top + CBAR_H / 2, anchor="e",
                      text=short_number(self.vmin), font=cb_font)
        c.create_text(x_left + CBAR_W + 6, top + CBAR_H / 2, anchor="w",
                      text=short_number(self.vmax), font=cb_font)

        # Logarithmic ticks: labelled decades; for a range of less than two
        # decades the 1-2-5 values are labelled instead
        decades = hi - lo
        for n in range(int(np.floor(lo)), int(np.floor(hi)) + 1):
            for m in range(1, 10):
                value = m * 10.0 ** n
                if not self.vmin <= value <= self.vmax:
                    continue
                labelled = (m == 1) if decades >= 2 else (m in (1, 2, 5))
                if not labelled and decades > 6:
                    continue                  # too many decades: no minor ticks
                x = x_of(value)
                c.create_line(x, bottom, x, bottom + (7 if labelled else 3))
                if labelled:
                    text = ("{:g}".format(value) if 0.01 <= value < 1e4
                            else "{}e{}".format(m, n))
                    c.create_text(x, bottom + 8, anchor="n", text=text,
                                  font=cb_font)

        c.create_text(VIEW_SIZE / 2, bottom + 28, anchor="n",
                      text="intensity (log scale)", font=cb_font)

    # --- Loading ---
    def load_image(self):
        path = filedialog.askopenfilename(
            title="Select a 32-bit TIFF image",
            filetypes=[("TIFF images", "*.tif *.tiff"), ("All files", "*.*")])
        if not path:
            return   # dialog cancelled

        try:
            data, orig_size, pos_min, data_max = load_tiff(path, VIEW_SIZE)
        except Exception as err:
            messagebox.showerror("Could not load image", str(err))
            return

        self.data = data
        self.name = path.split("/")[-1]
        self.orig_size = orig_size
        # Start with the full intensity range of the image
        self.vmin = pos_min
        self.vmax = data_max if data_max > pos_min else pos_min * 10.0

        self.min_entry.config(state=tk.NORMAL)
        self.max_entry.config(state=tk.NORMAL)
        self.update_entries()
        self.redraw()

    # --- Manual intensity limits ---
    def update_entries(self):
        self.min_var.set("{:.6g}".format(self.vmin))
        self.max_var.set("{:.6g}".format(self.vmax))

    def apply_range(self, event=None):
        if self.data is None:
            return
        try:
            new_min = float(self.min_var.get().replace(",", "."))
            new_max = float(self.max_var.get().replace(",", "."))
        except ValueError:
            self.update_entries()    # not a number: restore current values
            return

        if new_min <= 0 or new_max <= new_min:
            messagebox.showerror(
                "Invalid range",
                "Min must be greater than 0 and max must be greater than min.")
            self.update_entries()
            return

        # Redraw only if something actually changed
        if new_min != self.vmin or new_max != self.vmax:
            self.vmin = new_min
            self.vmax = new_max
            self.redraw()

    # --- Display ---
    def redraw(self):
        rgb = render_jet_log(self.data, self.vmin, self.vmax)
        self.photo = ImageTk.PhotoImage(rgb)
        self.canvas.delete("all")
        # Centre the image within the 700 x 700 area
        self.canvas.create_image(VIEW_SIZE // 2, VIEW_SIZE // 2,
                                 anchor="center", image=self.photo)
        self.draw_overlay()      # spots and lines go back on top of the image
        self.update_colorbar()
        self.status.config(
            text="{}   {}x{} px   displayed intensity {:.6g} .. {:.6g}".format(
                self.name, self.orig_size[0], self.orig_size[1],
                self.vmin, self.vmax))


if __name__ == "__main__":
    root = tk.Tk()
    app = ImageViewerApp(root)
    root.mainloop()
