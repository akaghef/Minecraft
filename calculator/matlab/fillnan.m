function ret = fillnan(a, b)
   a(isnan(a))=[];
   ret=nan(size(b));
   N=numel(a);
   M=numel(b);
   a(end+(1:M))=b;
   [~,u]=sort(a);
   v=reshape(find(u<=N),[1 N])-(0:N-1);
   w=1:M;
   w(v(v<=M))=[];
   w(end-(0:sum(v>M)-1))=[];
   x=zeros(1,M);
   x(w)=1;
    ret(~x)=a(1:N);
end

% Example usage:
