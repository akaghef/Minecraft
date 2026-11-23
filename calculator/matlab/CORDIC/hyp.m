n=40;
arr0=arrayfun(@atanh,2.^-(1:n));
arr1=arr0;
for ii=1:n
    x=arr0(ii);
    w=x-sum(arr1(arr1<x));
    if w>0
        idx=find(arr1>w,1,"last");
        arr1=arr1([1:idx idx idx+1:end]);
        disp(x)
    end
end
disp(-round(log2(arr1)))