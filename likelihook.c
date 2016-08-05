#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define Fs 	8000
#define Fh 	3400
#define Fl 	300
#define Na	256
#define M 	23
#define Pi 	3.14159265358979
#define L 	160
#define cep 	14 //1-12 he so cep + enery
#define frame 	4
#define mfccc 	4
#define doc 	4
#define Kmax 	8
#define lap 	5
#define N	4
#define W	4
typedef double tu[frame+1][mfccc+1];
typedef double motframe[mfccc+1];
typedef double vq[Kmax+1];
typedef double hmm[N+1];
typedef double matrix_A[N+1][N+1];
typedef double matrix_B[Kmax+1][N+1];

void alpha(int *y,hmm *A,hmm *B,double *Pi_cb,double *prob)
{
	hmm *alp=(hmm *)calloc(frame+1,sizeof(hmm));
	hmm *al=(hmm *)calloc(frame+1,sizeof(hmm));
	double *scale=(double *)calloc(frame+1,sizeof(double));
	int i,t,k,j,T;
	scale[1]=0;
	for (i=1;i<=N;i++)
	{
		alp[1][i] = Pi_cb[i] * B[y[1]][i];
		printf("pi:%f b:%f alp:%f \n", Pi_cb[i],B[y[1]][i],alp[1][i]);
		scale[1]+=alp[1][i];
		al[1][i]=Pi_cb[i] * B[y[1]][i];
	}
	printf("scale[1]: %f\n",scale[1]);
	for (i=1;i<=N;i++)
        {
                alp[1][i]=alp[1][i]/scale[1];
		printf("alp[1][%d]=%f \n",i,alp[1][i]);
	}
	T=y[0];
	for (t=2;t<=T;t++)
	{
		scale[t]=0;
		for (j=1;j<=N;j++)
		{
			alp[t][j]=0;
			for  (i=1;i<=N;i++)
			{
				alp[t][j]+=alp[t-1][i]*A[i][j];
				printf("alp[t:%d][j:%d]=%f;alp[t-1][i:%d]=%f;A[i][j]=%f\n",t,j,alp[t][j],i,alp[t-1][i],A[i][j]);
				al[t][j]+=al[t-1][i]*A[i][j];
			}
			printf("%d \n",y[t]);
			alp[t][j]*=B[y[t]][j];
			al[t][j]*=B[y[t]][j];
			printf("B[%d][%d]:%f alp[%d][%d]=%f\n",y[t],j,B[y[t]][j],t,j,alp[t][j]);
			scale[t]+=alp[t][j];
		}
		printf("scale[%d]=%f\n",t,scale[t]);
		for (j=1;j<=N;j++)
                {
			printf("alp=%f;  scale=%f\n",alp[t][j],scale[t]);
			alp[t][j]=alp[t][j]/scale[t];
			printf("alp[%d][%d] sau =%f\n",t,j,alp[t][j]);
		}
	}
	prob[0]=0;
	for (i=1;i<=N;i++)
	{
		prob[0]+=al[T][i];
	}
	printf("prob thuong=%f\n",log10(prob[0]));
	prob[0]=0;
	for (t=1;t<=T;t++)
	{
		prob[0]+=log10(scale[t]);
	}
	printf("prob scale=%f\n",prob[0]);
	free(alp);
	free(al);
	free(scale);
}
void main ()
{
	int w,n,t,k,h,i;
	hmm *A=(hmm *)calloc(N+1,sizeof(hmm));
	hmm *B=(hmm *)calloc(Kmax+1,sizeof(hmm));
	double *Pi_cb=(double *)calloc(N+1,sizeof(double));
	int *y=(int *)calloc(frame+1,sizeof(int));
	double *prob=(double *)calloc(1,sizeof(double));
	y[0]=4;
	printf("\n--------------Y----------------\n");
	for (t=1;t<=frame;t++)
	{
		y[t]=rand() %frame+1;
		printf("%d ",y[t]);
	}
	printf("\n-------------------------------\n");
	for (n=1;n<=N;n++)
	{
		Pi_cb[n]=rand() %10;
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
	printf("\n-----------------i--------------\n");
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
	printf("\n-----------Pi_cb---------------\n");
        for (n=1;n<=N;n++)
        {
                        printf("%f ",Pi_cb[n]);
        }
        printf("\n-------------------------------\n");
	alpha(y,A,B,Pi_cb,prob);
	printf ("\nprob: %f\n",prob[0]); 
	free(A);
	free(B);
	free(Pi_cb);
	free(y);
	free(prob);
}
