#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define Fs 	8000
#define Fh 	3400
#define Fl 	300
#define Num	256
#define M 	23
#define Pi 	3.14159265358979
#define L 	160
#define cep 	14 //1-12 he so cep + enery
#define frame 	399
#define mfccc 	26
#define doc 	100
#define Kmax 	16
#define lap 	100
#define N	6
#define W	4
typedef double tu[frame+1][mfccc+1];
typedef double motframe[mfccc+1];
typedef double vq[Kmax+1];
typedef double hmm[N+1];
typedef double matrix_A[N+1][N+1];
typedef double matrix_B[Kmax+1][N+1];
typedef int    obser[frame+1];
typedef double array_data[doc+1][frame+1][mfccc+1];
typedef double array_cb[Kmax+1][mfccc+1];

void train(obser *y,hmm *A,hmm *B,double *Pi_cb)
{
	hmm *alp=(hmm *)calloc(frame+1,sizeof(hmm));
	hmm *bet=(hmm *)calloc(frame+1,sizeof(hmm));
	double *scale=(double *)calloc(frame+1,sizeof(double));
	hmm *A_c=(hmm *)calloc(N+1,sizeof(hmm));
        hmm *B_c=(hmm *)calloc(Kmax+1,sizeof(hmm));
        hmm *A_cd=(hmm *)calloc(N+1,sizeof(hmm));
        hmm *B_cd=(hmm *)calloc(Kmax+1,sizeof(hmm));
	double *Pi_c=(double *)calloc(N+1,sizeof(double));
	int i,t,k,j,T,d,loop,n,w;
	double temp,tol=0.001,loglike_old,loglike_dif,loglike;
   	double loglike_c[doc+1];
    	double normal[N+1];;
	int max=1000;

	for(i=1;i<=N;i++)
    	{
        	for(j=1;j<=N;j++)
        	{
            		if((i==j)||(j==i+1))
                		A[i][j]=0.5;
            	else
                	A[i][j]=0;
//		printf("%f ",A[i][j]);
        	}
//		printf("\n");
    	}
    	A[N][N]=1;	
	Pi_cb[1]=1;
    	for(i=2;i<=N;i++)
        {
		Pi_cb[i]=0;	
	}
	srand((unsigned)(time(0)));
	for (i=1;i<=N;i++)
        {
            temp=0;
            for (k=1;k<=Kmax;k++)
                {
                    B[i][k]=(double)rand()/(double)RAND_MAX; //B[k][i]=(rand())/(float(RAND_MAX)+1);
                    temp=temp+B[i][k];
                }

            for (k=1;k<=Kmax;k++)                              //Normalized
                {
                     B[i][k]= B[i][k]/temp;                   //chuan hoa
                }

        }	
/*	printf("\n--------------A----------------\n");
        for (n=1;n<=N;n++)
        {
                for (w=1;w<=N;w++)
                {
			A[n][w]=rand() %100;
                        printf("%f ",A[n][w]);
                }
                printf("\n");
        }
        printf("-------------------------------\n");
        printf("\n--------------B----------------\n");
        for (n=1;n<=Kmax;n++)
        {
                for (w=1;w<=N;w++)
                {
			B[n][w]=rand() %100;
                        printf("%f ",B[n][w]);
                }
                printf("\n");
        }
        printf("-------------------------------\n");
        printf("\n-----------Pi_cb---------------\n");
        for (n=1;n<=N;n++)
        {
			Pi_cb[n]=rand() %100;
                        printf("%f ",Pi_cb[n]);
        }
        printf("\n-------------------------------\n");	
*/	loglike_old=-1000;       // From previous itertion.
    	loglike_dif=1000;        // Diffrence
    	loop=0;	
	while((loop<max)&&(loglike_dif>=tol))
        {	
            	loop=loop+1;
            	for (i=1;i<=N;i++)
		{	      // Initialize sum over A
            	    	for (j=1;j<=N;j++)
                	{   
				A_c[i][j]=0;
                    		A_cd[i][j]=0;
                	}
		}
            	for (i=1;i<=N;i++)      // Initialize sum over B
                {
			for (k=1;k<=Kmax;k++)
                	{   
				B_c[i][k]=0;
                    		B_cd[i][k]=0;
                	}
		}
            	for (i=1;i<=N;i++)      // Initialize sum over Pi
                {
                    Pi_c[i]=0;
                }
		for (d=1;d<=doc;d++)
		{
			//alpha calculate
			scale[1]=0;
			for (i=1;i<=N;i++)
			{	
				alp[1][i] = Pi_cb[i] * B[y[d][1]][i];
//				printf("pi:%f b:%f alp:%f \n", Pi_cb[i],B[y[d][1]][i],alp[1][i]);
				scale[1]+=alp[1][i];
			}
//			printf("scale[1]: %f\n",scale[1]);
			for (i=1;i<=N;i++)
        		{
        	        	alp[1][i]=alp[1][i]/scale[1];
//				printf("alp[1][%d]=%f \n",i,alp[1][i]);
			}
			T=y[d][0];
			for (t=2;t<=T;t++)
			{
				scale[t]=0;
				for (j=1;j<=N;j++)
				{
					alp[t][j]=0;
					for  (i=1;i<=N;i++)
					{
						alp[t][j]+=alp[t-1][i]*A[i][j];
//						printf("alp[t:%d][j:%d]=%f;alp[t-1][i:%d]=%f;A[i][j]=%f\n",t,j,alp[t][j],i,alp[t-1][i],A[i][j]);
					}
//					printf("%d \n",y[t]);
					alp[t][j]*=B[y[d][t]][j];
//					printf("B[%d][%d]:%f alp[%d][%d]=%f\n",y[t],j,B[y[t]][j],t,j,alp[t][j]);
					scale[t]+=alp[t][j];
				}
//				printf("scale[%d]=%f\n",t,scale[t]);
				for (j=1;j<=N;j++)
                		{
//					printf("alp=%f;  scale=%f\n",alp[t][j],scale[t]);
					alp[t][j]=alp[t][j]/scale[t];
//					printf("alp[%d][%d] sau =%f\n",t,j,alp[t][j]);
				}
			}	
			loglike_c[d]=0;
			for (t=1;t<=T;t++)
			{
//				printf("%f ",scale[t]);
				loglike_c[d]+=log10(scale[t]);
			}
//			printf("loop=%d; doc=%d; prob=%f\n",loop,d,loglike_c[d]);
			//beta calculate
			for (i=1;i<=N;i++)
        		{
        	        	bet[T][i]=1/scale[T];
        		}
        		for (t=T-1;t>=1;t--)
        		{
        	        	for (i=1;i<=N;i++)
        	        	{
        	                	bet[t][i]=0;
        	                	for (j=1;j<=N;j++)
              				{
                        	        	bet[t][i]+=A[i][j]*B[y[d][t+1]][j]*bet[t+1][j];
//                      	          	printf("t=%d;i=%d,j=%d;A[i][j]=%f ; y[t+1]=%d;B[y][j]=%f;bet[t+1][j]=%f;bet[t][i]=%f\n\n",t,i,j,A[i][j],y[t+1],B[y[t+1]][j],bet[t+1][j],bet[t][i]);
                        		}
//					printf("bet=%f; scale=%f\n",bet[t][i],scale[t]);
					bet[t][i]=bet[t][i]/scale[t];
//					printf("bet=%f\n",bet[t][i]);
//                      	  	printf("\n\n");
                		}	
//              	  	printf("\n\n");
        		}	
/*			for (t=1;t<=T;t++o)
			{
				for (i=1;i<=N;i++)
				{
					printf("%f ",bet[t][i]);
				}
				printf("\n");
			}
*/			for(i=1;i<=N;i++)
                    	{
                        	for(j=1;j<=N;j++)
                        	{
                            		for (t=1;t<=T-1;t++)
                            		{
                                		A_c[i][j]=A_c[i][j]+alp[t][i]*A[i][j]*B[y[d][t+1]][j]*bet[t+1][j];
                                		A_cd[i][j]=A_cd[i][j]+alp[t][i]*bet[t][i];
//						printf("t=%d;i=%d,j=%d,d=%d;A[i][j]=%f ; y[t+1]=%d;B[y][j]=%f;bet[t+1][j]=%f;A_c[i][j]=%f;A_cd[i][j]=%f\n\n",t,i,j,d,A[i][j],y[d][t+1],B[y[d][t+1]][j],bet[t+1][j],A_c[i][j],A_cd[i][j]);
                            		}
               			}	
			}
			for(j=1;j<=N;j++)
			{ //  normal[j]=0;
                      		for (k=1;k<=Kmax;k++)
                            	{
                                	for (t=1;t<=T;t++)
                                	{
                                   		if (y[d][t]==k)
						{
                                        		B_c[k][j]=B_c[k][j]+alp[t][j]*bet[t][j];
						}  //*scale[t] matlab co;
						B_cd[k][j]=B_cd[k][d]+alp[t][j]*bet[t][j];   // 
					}
                               // B_cd[k][j]=B_cd[k][j]/scale[T];
  				}
                        }
			for(i=1;i<=N;i++)
                        {
                            Pi_c[i]=Pi_c[i]+alp[1][i]*bet[1][i]*scale[1];
//				printf("%f ", Pi_c[i]);
                        }
//		printf("\n-------------------end doc-----------------------------\n");
		}
		loglike=0;
		for (d=1;d<=doc;d++)
		{
			loglike+=loglike_c[d];
		}
		loglike_dif=loglike-loglike_old;
            	loglike_old=loglike;

		for(i=1;i<=N;i++)
		{
            		for(j=1;j<=N;j++)
			{	
                		A_c[i][j]=A_c[i][j]/A_cd[i][j];
			}
		}
            	for(i=1;i<=N;i++)
            	{   
			normal[i]=0;
                	for (j=1;j<=N;j++)
			{
                    		normal[i]=normal[i]+A_c[i][j];
			}
            	}

            	for(i=1;i<=N;i++)
		{
            		for(j=1;j<=N;j++)
			{
                		A[i][j]=A_c[i][j]/normal[i];
			}
		}

		for(k=1;k<=Kmax;k++)
		{
            		for(j=1;j<=N;j++)
			{
                		B_c[k][j]=B_c[k][j]/B_cd[k][j];
			}
		}

            	for(j=1;j<=N;j++)
            	{   
			normal[j]=0;
                	for (k=1;k<=Kmax;k++)
			{
                    		normal[j]=normal[j]+B_c[k][j];
            		}
		}

            	for(j=1;j<=N;j++)
		{
            		for (k=1;k<=Kmax;k++)
			{
                		B[k][j]=B_c[k][j]/normal[j];
			}
		}
            // nornalize for Pi1
            	temp=0;
            	for(i=1;i<=N;i++)
		{
                	temp=temp+Pi_c[i];
		}
            	for(i=1;i<=N;i++)
		{
                	Pi_cb[i]=Pi_c[i]/temp;	
//			printf("pic=%f; temp=%f; picb=%f \n",Pi_c[i],temp, Pi_cb[i]);	
		}
//	printf("\n------------------end loop---------------------\n");
	}
	free(alp);
	free(bet);
	free(scale);
}

void training(array_data *data,array_cb *cb,matrix_A *A,matrix_B *B, hmm *Pi_cb)
{
	int i,j,k,w,T,d,t;
	double dist[Kmax+1];
	obser *y=(obser *)calloc(doc+1,sizeof(obser));
	for (w=1;w<=W;w++)
	{
		for (d=1;d<=doc;d++)
		{
			T=data[w][d][0][0];
			y[d][0]=T;
			for (t=1;t<=T;t++)
			{
				y[d][t]=1;
				for (k=1;k<=Kmax;k++)
				{
					dist[k]=0;
					for (j=1;j<=mfccc;j++)
					{
						dist[k]+=(data[w][doc][t][j]-cb[w][k][j])*(data[w][doc][t][j]-cb[w][k][j]);
					}
					if (dist[k]<dist[y[d][t]])
					{
						y[d][t]=k;
					}
				}
			} 
		}
		train(y,A[w],B[w],Pi_cb[w]);
	}
}

void main ()
{
	int w,n,t,k,h,i;
	array_cb *cb=(array_cb *)calloc(W+1,sizeof(array_cb));
    	array_data *data=(array_data *)calloc(W+1,sizeof(array_data));
	matrix_A *A=(matrix_A  *)calloc(W+1,sizeof(matrix_A ));
	matrix_B *B=(matrix_B *)calloc(W+1,sizeof(matrix_B));
	hmm *Pi_cb=(hmm *)calloc(W+1,sizeof(hmm));
	free(A);
	free(B);
	free(Pi_cb);
	free(cb);
	free(data);
}
