classdef Ucore
    properties
        n int64
        s=false%true=minus
        e
    end
    properties (Constant)
        Max=int64(10^13);
    end
    methods
        function obj=Ucore (N)
            obj.n=N+double(N<0)*obj.Max;
            obj.s=(N<0);
        end
        function obj=shift(obj0,N)
            if nargin==1
                N=1;
            end
            D=idivide(u2s(obj0),int64(10^N));
            obj=Ucore(D);
        end
        function [obj,sgn]=plus(obj0,obj1)
            obj=obj0;
            obj.n=obj0.n+obj1.n;
            sgn=abs(obj.n)>obj.Max;
            if sgn
                obj.n=obj.n-obj.Max;
            end
            obj.s=xor(obj0.s,sgn);
        end
        function [obj,sgn]=minus(obj0,obj1)
            [obj,sgn]=plus(obj0,-obj1);
            obj.s=~obj.s;
        end
        function obj=uminus(obj)
            obj.n=obj.Max-obj.n;
            obj.s=~obj.s;
        end

        function out=lt(obj0,obj1)
            out=(u2s(obj0)<u2s(obj1));
        end
        function out=eq(obj0,obj1)
            out=(u2s(obj0)==u2s(obj1));
        end
        function out=gt(obj0,obj1)
            out=lt(obj1,obj0);
        end
        function out=le(obj0,obj1)
            out=lt(obj0,obj1)&eq(obj0,obj1);
        end
        function out=ge(obj0,obj1)
            out=lt(obj1,obj0)&eq(obj0,obj1);
        end
        function out=ne(obj0,obj1)
            out=~eq(obj0,obj1);
        end
        function obj=add(obj0,obj1,sgn,ntimes)
            %sgn==trueならば減算
            if nargin==3
                ntimes=1;
            end
            obj=obj0;
            for iter=1:ntimes
                if sgn
                    obj=obj.minus(obj1);
                else
                    obj=obj.plus(obj1);
                end
            end

        end
        function out=d(obj)
            out=double(obj.n)/double(obj.Max)*10;
            fprintf( '%.12f\n', out);
        end
        function out=do(obj)
            out=double(obj.n)/double(obj.Max)*10;
        end
    end
end
function ret=u2s(c)
    if c.s
        ret=c.n-c.Max;
    else
        ret=c.n;
    end
end
function ret=s2u(c)
    ret=c;
    if ret.n<0
        ret.n=ret.Max+ret.n;
    end
end
