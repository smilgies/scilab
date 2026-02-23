// dlib > sort > sort matrix by a specific column using gsort

function out=sort_by_col(in,col_num)
    [v k]=gsort(in(:,col_num),'g','i');
    out=in(k(:),:);
endfunction
