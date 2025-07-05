#include <stdio.h>


double seq(int n) {
    if (n == 1)
        return 3.0;
    else if (n == 2)
        return 4.0;
    else
        return 0.5 * seq(n - 1) + 2.0 * seq(n - 2);
}

/*

                      f1(5)
                    /      \
               f2(4)        f10(3)
              /     \       /     \
         f3(3)     f8(2)  f11(2)  f13(1)
        /    \       |       |      
   f4(2)   f6(1)    f9(1)  f12(1)  
   /   \                    
f5(1) f7(0)


*/

int main() {
    printf("r_sequence.c\n\n");

    int n;
start:

    printf("n = ");
    
    scanf("%d", &n);
    
    if (getchar() != '\n') {
        
        while (getchar() != '\n');

        goto start;
    }
    
     if (n <= 0) {
    	goto start;
	}

    double result = seq(n);
    printf("seq(%d) = %lf\n", n, result);

    return 0;
}
