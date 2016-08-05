#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define Fs 	8000
#define Fh 	3400
#define Fl 	300
#define N 	256
#define M 	23
#define Pi 	3.14159265358979
#define L 	160
#define cep 	14 //1-12 he so cep + enery
#define frame 	4
#define mfccc 	4
#define doc 	4
#define Kmax 	8
#define lap 	5
typedef double tu[frame+1][mfccc+1];
typedef double motframe[mfccc+1];
typedef double vq[Kmax];

void kmean(tu *a ,motframe *b)
{
	int i,j,k,T=0,Tp=0,index[Kmax+1],h,count;
	motframe *sub=(motframe *)calloc(doc*frame +1,sizeof(motframe));
	int *c=(int *)calloc(doc*frame +1,sizeof(int));
	vq *kc=(vq *)calloc(doc*frame +1,sizeof(vq ));
	for (i=1;i<=doc;i++)
	{
		Tp=T;
		T=T+a[i][0][0];
		//printf("T: %d Tp: %d\n",T,Tp);
		for (j=1+Tp;j<=T;j++)
		{
			for (k=1;k<=mfccc;k++)
			{
				sub[j][k]=a[i][j-Tp][k];	
			}
		}
	}
/*	printf("\n--------sub--------------\n");
	for (i=1;i<=T;i++)
	{
		for (j=1;j<=mfccc;j++)
		{
			printf("%f ",sub[i][j]);
		}
		printf("\n");
	}
	printf("\n-------------------------\n");
	printf("T: %d \n",T);
*/	for (i=1;i<=Kmax;i++)
	{
		index[i]=rand() %T +1;
		j=1;
		while (j<i)
		{
			if (index[i]==index[j])
			{
				i--;
			}
			j++;
		}
	}
/*	for (i=1;i<=Kmax;i++)
        {
		printf("%d ",index[i]);
	}	
	printf("\n");
	printf("\nb la \n");
*/	for (i=1;i<=Kmax;i++)
	{
		for (j=1;j<=mfccc;j++)
		{
			b[i][j]=sub[index[i]][j];
//			printf("%f ",b[i][j]);
		}
//		printf("\n");
	}
	for (h=1;h<=lap;h++)
	{
		for (i=1;i<=T;i++)
		{	
			c[i]=1;
			for (j=1;j<=Kmax;j++)
			{
				kc[i][j]=0;
				for (k=1;k<=mfccc;k++)
				{
					kc[i][j]+=(sub[i][k]-b[j][k])*(sub[i][k]-b[j][k]);
				}
				if (kc[i][j]<kc[i][c[i]])
				{
					c[i]=j;
				}
			}
//			printf ("%d ",c[i]);
		}
//		printf("\n");
		for (k=1;k<=Kmax;k++)
		{
			for (j=1;j<=mfccc;j++)
			{
				b[k][j]=0;
			}
			count=0;
			for (i=1;i<=T;i++)
			{
				if (c[i]==k)
				{
					count++;
					for (j=1;j<=mfccc;j++)
					{
						b[k][j]+=sub[i][j];
					}
				}
			}
//			printf("set %d co %d\n",k,count);
			if (count >=1)
			{
				for (j=1;j<=mfccc;j++)
				{
					b[k][j]=b[k][j]/count;
				}
			}
		}
	}
/*	printf("\n-----------b---------- \n");	
	for (i=1;i<=Kmax;i++)
        {
                for (j=1;j<=mfccc;j++)
                {
                        printf("%f ",b[i][j]);
                }
                printf("\n");
        }
	printf("\n---------------------- \n");
*/	free(kc);
	free(c);
	free(sub);
}
void main()
{
	int i,j,k;
	tu *a =(tu *)calloc(doc+1,sizeof(tu));
	motframe *b =(motframe *)calloc(Kmax+1,sizeof(motframe));
	for (i=1;i<=doc;i++)
	{
		a[i][0][0]=i;
		for (j=1;j<=frame;j++)
                {
                        for (k=1;k<=mfccc;k++)
                        {
                                a[i][j][k]=i+j;
//				printf("%f ",a[i][j][k]);
                        }
//			printf("\n");
                }
//		printf("--------------\n");
	}
	kmean(a,b);
	printf("\n\n");
	free(a);
	free(b);
}
