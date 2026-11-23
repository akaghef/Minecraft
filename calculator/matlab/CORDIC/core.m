classdef core
    properties
        n int64
        s=false
        e
    end
    properties (Constant)
        Max=int64(10^13);
    end
    methods
        function obj=core (N)
            obj.n=N;
        end
        function obj=shift(obj0,N)
            obj=obj0;
            if nargin==1
                N=1;
            end
            obj.n=idivide(obj0.n,int64(10^N));

        end
        function [obj,sgn]=plus(obj0,obj1)
            obj=obj0;
            obj.n=obj0.n+obj1.n;
            sgn=abs(obj.n)>obj.Max;
        end
        function [obj,sgn]=minus(obj0,obj1)
            [obj,sgn]=plus(obj0,-obj1);
        end
        function obj=uminus(obj)
            obj.n=-obj.n;
            obj.s=~obj.s;
        end

        function out=lt(obj0,obj1)
            out=(obj0.n<obj1.n);
        end
        function out=eq(obj0,obj1)
            out=(obj0.n==obj1.n);
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
        function obj=mtimes(obj0,A)
            obj=obj0;
            obj.n=A*obj.n;
        end
        function out=d(obj)
            out=double(obj.n)/double(obj.Max)*10;
            fprintf( '%.12f\n', out);
        end
        function out=do(obj)
            out=double(obj.n)/double(obj.Max)*10;
        end
        function out=d2(obj)
            if obj.n<0
                obj.n=obj.Max+obj.n-1;
            end
            out=double(obj.n)/double(obj.Max)*10;
            fprintf( '%.12f\n', out);
        end
    end
end
