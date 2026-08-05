// classify 2D
// part I: no forbidden or unobserved rods
//         hexagonal
//         rhombic/square
//         oblique/rectangular
//         oblique special case
//         multiples of a

// Example: ZnPc vapor deposition on graphene (JACS )
qlist=[4.65;6.1;7.1;9.3;9.8;11.0;12.1;14.0;15.4;17.9;18.2;18.5;18.7;19.5;19.9;21.2;21.5];

///////////////////////////////////////////////////////////////////////
// calcdev: calculate deviation
// - for each qi find nearest qhk
// - sum up deviations

// deviation from exp lattice
function dev=calcdev(a,b,gam,qlist,flag,num)

    // generate trial q-values    
    n=0;
    for h=-5:5
        for k=-5:5
            n=n+1;
            qhk(n)=sqrt(h*h*a*a+k*k*b*b+2*h*k*a*b*cos(gam));
        end
    end
    qhk=gsort(qhk,"g","i");
    // remove doubles and zero
    qhk=qhk(2:2:$);

    // print selected q-values and qlist
    if flag then
        disp(round(qhk(1:M)'*100)/100);
        disp(qlist');
    end

    // plot trial q's and qlist
    if num>0 then
        col=["r.";"m.";"b.";"g.";"c."];
        icol = pmodulo(num-1,5)+1;
        fig=scf(3);
        y=ones(qhk)*num;
        plot(qhk,y,col(icol));
    end

    // calculate deviation of closest qhk from qlist point
    M=length(qlist);
    dev=0;
    for i=1:M
        // starting point
        distold=abs(qhk(1)-qlist(i));
        for k=2:2*M
            // find best matching qhk
            dist=abs(qhk(k)-qlist(i));
            if dist<=distold then
                distold=dist;
            else
                dist=distold;
                break;
            end
        end
        // sum distances
        dev=dev+dist;
    end
    // normalize
    dev=dev*10/M;

endfunction


//////////////////////////////////////////////////////////////////////
// MAIN
//

// for graphics output
fig=scf(3);
fig.tag="plot";
ax=gca();
ax.tag="plotaxes";

// plot size: auto adjusting
dq = round((qlist($) - qlist(1))/10);
qmin = round(qlist(1)) - dq;
qmax = round(qlist($)) + dq;
M = length(qlist);

// plot experimental list of q-values
drawlater;
for i=1:M
    plot([qlist(i),qlist(i)],[0,13],"k-");
end
ax.tight_limits = "on";
ax.data_bounds = [qmin,0; qmax,7];
drawnow;

//
// going through the list of possible assignments
//

disp("triclinic, no missing rods");

// case 1: a = b = d
text="Case 1: ";
a=qlist(1);
text=text+"a="+string(round(a*100)/100)+", ";
b=qlist(1);
text=text+"b="+string(round(b*100)/100)+", ";
d=qlist(1);
text=text+"d="+string(round(d*100)/100)+", ";
gam=60;
text=text+"gam="+string(round(gam*10)/10)+", ";
lim=60;
text=text+"lim="+string(round(lim*10)/10)+", ";
dev=calcdev(a,b,gam*%pi/180,qlist,%f,1);
text=text+"dev="+string(round(dev*10)/10);
disp(text);
reslist=[a,b,gam,lim,dev];

// case 2: a = b < d
text="Case 2: ";
a=qlist(1);
text=text+"a="+string(round(a*100)/100)+", ";
b=qlist(1);
text=text+"b="+string(round(b*100)/100)+", ";
d=qlist(2);
text=text+"d="+string(round(d*100)/100)+", ";
gam=acos((a*a+b*b-d*d)/(2*a*b));
gamdeg=gam*180/%pi;
text=text+"gam="+string(round(gamdeg*10)/10)+", ";
lim=acos(a/(2*b));
limdeg=lim*180/%pi;
text=text+"lim="+string(round(limdeg*10)/10)+", ";
dev=calcdev(a,b,gam,qlist,%f,2);
text=text+"dev="+string(round(dev*10)/10);
disp(text);
reslist=[reslist;a,b,gam,lim,dev];

// case 3: a < b < d
text="Case 3: ";
a=qlist(1);
text=text+"a="+string(round(a*100)/100)+", ";
b=qlist(2);
text=text+"b="+string(round(b*100)/100)+", ";
d=qlist(3);
text=text+"d="+string(round(d*100)/100)+", ";
gam=acos((a*a+b*b-d*d)/(2*a*b));
gamdeg=gam*180/%pi;
text=text+"gam="+string(round(gamdeg*10)/10)+", ";
lim=acos(a/(2*b));
limdeg=lim*180/%pi;
text=text+"lim="+string(round(limdeg*10)/10)+", ";
dev=calcdev(a,b,gam,qlist,%f,3);
text=text+"dev="+string(round(dev*10)/10);
disp(text);
reslist=[reslist;a,b,gam,lim,dev];

// case 4: a < b = d
text="Case 4: ";
a=qlist(1);
text=text+"a="+string(round(a*100)/100)+", ";
b=qlist(2);
text=text+"b="+string(round(b*100)/100)+", ";
d=qlist(2);
text=text+"d="+string(round(d*100)/100)+", ";
gam=acos((a*a+b*b-d*d)/(2*a*b));
gamdeg=gam*180/%pi;
text=text+"gam="+string(round(gamdeg*10)/10)+", ";
lim=acos(a/(2*b));
limdeg=lim*180/%pi;
text=text+"lim="+string(round(limdeg*10)/10)+", ";
dev=calcdev(a,b,gam,qlist,%f,4);
text=text+"dev="+string(round(dev*10)/10);
disp(text);
reslist=[reslist;a,b,gam,lim,dev];

// there are always 4 cases to be checked
ncase=4;


// checking for multiples of a < b up to n=5
for n=2:5
    if qlist(n)==n*qlist(1) then
        disp("warning: multiples of a detected: n = "+string(n));
        text="Case 5: ";
        a=qlist(1);
        text=text+"a="+string(round(a*100)/100)+", ";
        b=qlist(n+1);
        text=text+"b="+string(round(b*100)/100)+", ";
        d=qlist(n+2);
        text=text+"d="+string(round(d*100)/100)+", ";
        gam=acos((a*a+b*b-d*d)/(2*a*b));
        gamdeg=gam*180/%pi;
        text=text+"gam="+string(round(gamdeg*10)/10)+", ";
        lim=acos(a/(2*b));
        limdeg=lim*180/%pi;
        text=text+"lim="+string(round(limdeg*10)/10)+", ";
        dev=calcdev(a,b,gam,qlist,%f,5);
        text=text+"dev="+string(round(dev*10)/10);
        disp(text);
        reslist($,:)=[a,b,gam,lim,dev];
        ncase=5;
    else
        // if no multiples found, abandon search
        disp("Case 5: no multiples of a found");
        break;
    end
end

// checking for multiples of a < b up to n=5 and b=d
for n=2:5
    if qlist(n)==n*qlist(1) then
        disp("warning: multiples of a detected: n = "+string(n));
        text="Case 6: ";
        a=qlist(1);
        text=text+"a="+string(round(a*100)/100)+", ";
        b=qlist(n+1);
        text=text+"b="+string(round(b*100)/100)+", ";
        d=qlist(n+1);
        text=text+"d="+string(round(d*100)/100)+", ";
        gam=acos((a*a+b*b-d*d)/(2*a*b));
        gamdeg=gam*180/%pi;
        text=text+"gam="+string(round(gamdeg*10)/10)+", ";
        lim=acos(a/(2*b));
        limdeg=lim*180/%pi;
        text=text+"lim="+string(round(limdeg*10)/10)+", ";
        dev=calcdev(a,b,gam,qlist,%f,5);
        text=text+"dev="+string(round(dev*10)/10);
        disp(text);
        reslist($,:)=[a,b,gam,lim,dev];
        ncase=6;
    else
        // if no multiples found, abandon search
        disp("Case 6: no multiples of a found")
        break;
    end
end

// checking for multiples of a < b up to n=5 and b < n a < d
for n=2:5
    if qlist(n)==n*qlist(1) then
        disp("warning: multiples of a detected: n = "+string(n));
        text="Case 7: ";
        a=qlist(1);
        text=text+"a="+string(round(a*100)/100)+", ";
        b=qlist(2);
        text=text+"b="+string(round(b*100)/100)+", ";
        d=qlist(n+2);
        text=text+"d="+string(round(d*100)/100)+", ";
        gam=acos((a*a+b*b-d*d)/(2*a*b));
        gamdeg=gam*180/%pi;
        text=text+"gam="+string(round(gamdeg*10)/10)+", ";
        lim=acos(a/(2*b));
        limdeg=lim*180/%pi;
        text=text+"lim="+string(round(limdeg*10)/10)+", ";
        dev=calcdev(a,b,gam,qlist,%f,5);
        text=text+"dev="+string(round(dev*10)/10);
        disp(text);
        reslist($,:)=[a,b,gam,lim,dev];
        ncase=7;
    else
        // if no multiples found, abandon search
        disp("Case 7: no multiples of a found");
        break;
    end
end

// reduce plot limit if less cases are found
ax.tight_limits = "on";
ax.data_bounds = [qmin,0; qmax,ncase+1];
xlabel("q (1/nm)","font_size",4);
ylabel("case","font_size",4);




