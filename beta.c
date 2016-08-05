#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define Fs      8000
#define Fh      3400
#define Fl      300
#define Na      256
#define M       23
#define Pi      3.14159265358979
#define L       160
#define cep     14 //1-12 he so cep + enery
#define frame   4
#define mfccc   4
#define doc     4
#define Kmax    8
#define lap     5
#define N       4
#define W       4
typedef double tu[frame+1][mfccc+1];
typedef double motframe[mfccc+1];
typedef double vq[Kmax+1];
typedef double hmm[N+1];
typedef double matrix_A[N+1][N+1];
typedef double matrix_B[Kmax+1][N+1];

void beta(int *y,hmm *A,hmm *B,hmm *bet)
{
	int i,j,t,T;
	T=y[0];
	for (i=1;i<=N;i++)
	{
		bet[T][i]=1;
	}
	for (t=T-1;t>=1;t--)
	{
		for (i=1;i<=N;i++)
		{
			bet[t][i]=0;
			for (j=1;j<=N;j++)
			{
				bet[t][i]+=A[i][j]*B[y[t+1]][j]*bet[t+1][j];
				printf("t=%d;i=%d,j=%d;A[i][j]=%f ; y[t+1]=%d;B[y][j]=%f;bet[t+1][j]=%f;bet[t][i]=%f\n\n",t,i,j,A[i][j],y[t+1],B[y[t+1]][j],bet[t+1][j],bet[t][i]);
			}
			printf("\n\n");
		}
		printf("\n\n");
	}
}

void main()
{
	int i,j,t,T,n,w,k;
	hmm *A=(hmm *)calloc(frame+1,sizeof(hmm));
	hmm *B=(hmm *)calloc(Kmax+1,sizeof(hmm));
	hmm *bet=(hmm *)calloc(frame+1,sizeof(hmm));
	int *y=(int *)calloc(frame+1,sizeof(int));
	y[0]=4;
	T=y[0];
        printf("\n--------------Y----------------\n");
        for (t=1;t<=frame;t++)
        {
                y[t]=rand() %frame+1;
                printf("%d ",y[t]);
        }
        printf("\n-------------------------------\n");
        for (n=1;n<=N;n++)
        {
                for (w=1;w<=N;w++)
                {
                        A[n][w]=rand() %10;
                }
                for (k=1;k<=Kmax;k++)
                {
                        B[k][n]=rand() %10;
                }
        }
        printf("\n--------------A----------------\n");
        for (n=1;n<=N;n++)
        {
                for (w=1;w<=N;w++)
                {
                        printf("%f ",A[n][w]);
                }
                printf("\n");
        }
        printf("\n-------------------------------\n");
        printf("\n--------------B----------------\n");
        for (n=1;n<=Kmax;n++)
        {
                for (w=1;w<=N;w++)
                {
                        printf("%f ",B[n][w]);
                }
                printf("\n");
        }
        printf("\n-------------------------------\n");
	beta(y,A,B,bet);
	printf("\n--------------Bet--------------\n");
        for (n=1;n<=T;n++)
        {
                for (w=1;w<=N;w++)
                {
                        printf("%f ",bet[n][w]);
                }
                printf("\n");
        }
        printf("\n-------------------------------\n");


}
