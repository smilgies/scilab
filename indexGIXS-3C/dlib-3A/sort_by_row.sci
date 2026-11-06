// dlib > sort > sort matrix by specific row

function out=sort_by_row(in,row_num)
    [v k]=gsort(in(row_num,:),'g','i');
    out=in(:,k(:));
endfunction
