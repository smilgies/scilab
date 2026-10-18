Never say never! Fooling around with my little Raspberry Pi 5 with only 2 GB RAM, I was curious whether it could should x-ray images on the log scale, using the help of my AI buddy Claude Sonnet 5.5 low. One thing led to another, and before I knew it, Claude had put together the GUI. So what, I thought, let's add some wild calculations and see whether Claude and the RPi 5 could handle it. Yes, wow, and that at lightning speed! Only using the limited Debian python distribution with numpy and tkinter. And I added matplotlib, which also gave me PIL and scipy bundled with it. Cool!

Conclusion: Python code has amazing performance, even on this limited hardware. But coming from the Matlab/Scilab world, the actual coding is mostly a mystery to me... But that's what friends are for...

Long story short, in the course of the day I kept adding bits and pieces. Maybe not yet the most beautiful GUI, but getting there. And full indexGIXS-3 capabilities. Here some first examples, and whenever I can continue, some more finetuning.

Other than that, the functionality is very similar to indexGIXS-3, check out the documentation there. The detector menu was not needed, so far all TIFF formats are supported by PIL. Berkeley GB files can just be renamed as TIFF. Remains to be seen what to do about EDF. But so far so good!
