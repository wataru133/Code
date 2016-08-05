#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define Fs 	8000
#define Fh 	3400
#define Fl 	300
#define Num 	256
#define M 	23
#define Pi 	3.14159265358979
#define L 	160
#define cep 	14 //1-12 he so cep + enery
#define frame 	399
#define mfccc 	26
#define doc 	10
#define Kmax 	16
#define lap 	100
#define W	4
typedef double tu[frame+1][mfccc+1];
typedef double motframe[mfccc+1];
typedef double vq[Kmax+1];
typedef double array_data[doc+1][frame+1][mfccc+1];
typedef double array_cb[Kmax+1][mfccc+1];

int framing(double s[Fs*4],double e[],double a[][L])
{
    int i,j,k,h=0;
    double c,b[frame][L],e1[frame];
    double *sp = (double *)calloc(Fs*4,sizeof(double));
    sp[0]=s[0];
    for(i = 1; i < 32000; i++)
    {
        sp[i]=s[i]-0.97*s[i-1];
    }

    for (i=0 ; i<frame; i++)
    {
        for (j=0; j<L; j++)
        {
            a[i][j]=s[80*i+j];
            b[i][j]=sp[80*i+j];
        }
    }
    for (j=0 ; j<frame; j++)
    {
        c=0;
        for (k=0; k<L; k++)
        {
            c +=a[j][k]*a[j][k];
            e1[j]=log(c)/log(10);
        }
        if (e1[j]>(1.5*e1[0]))
        {
            for (k=0; k<L; k++)
            {
		s[80*h+k]=a[j][k];
                a[h][k]=b[j][k];
            }
            e[h]=e1[j];
            h +=1;
        }
    }
//  printf("%d",h);
    return h;
    free(sp);
}

void windowing(double a[][L],double aw[][L],int t)
{
    int i,j;
    float b,h[L];
    for (i=1;i<=L;i++)
    {
        b=(2*Pi*(i-1))/(L-1);
        h[i-1]=0.54-0.46*cos(b);
    }
    for (j=0; j<t; j++)
    {
        for (i=0; i<L; i++)
        {
            aw[j][i] = a[j][i]*h[i];
        }
    }
}

void FFT( double sr[Num], double si[Num],double Sr[Num],double Si[Num])
{
    double a=0,b=0;
    int k,n;
    for (k=0; k<Num ; k++)
    {
        si[k]=0;
        Sr[k]=0;
        Si[k]=0;
        for (n=0; n<Num; n++)
        {
            a= sr[n]*cos(2*Pi*k*n/Num) + si[n]*sin(2*Pi*k*n/Num);
            b=-(sr[n]*sin(2*Pi*k*n/Num)-si[n]*cos(2*Pi*k*n/Num));
            Sr[k] += a;
            Si[k] +=b;
        }
    }
}

void Mel_fre(double ar[][Num], double ai[][Num], double C[][cep],int t)
{
    double F[M+2], Hm[Num], Xa[t][Num],T[M],S[t][M];
    int m,k,i,j,n;
    double B(double f)
    {
        double a;
        a=1125*log(1 + f/700);
        return(a);
    }
    double B_inv(double b)
    {
        double c;
        c=700*(exp(b/1125)-1);
        return(c);
    }
    for (i=0; i<t; i++)
    {
        for (j=0; j<Num; j++)
        {
            Xa[i][j]= ar[i][j]*ar[i][j] + ai[i][j]*ai[i][j];
        }
    }
    for (i=0; i<t; i++)
    {
        for (m=0; m<=M+1 ; m++)
        {
            F[m]=Num*B_inv(B(Fl) + m*(B(Fh) - B(Fl))/(M+1))/Fs;
        }
        for (m=1; m<=M ; m++)
        {
            T[m-1]=0;
            for (k=0; k<Num ; k++)
            {
                if (k<F[m-1])
                {
                    Hm[k]=0;
                }
                else if ((k>=F[m-1])&&(k <= F[m]))
                {
                    Hm[k] = (2*(k - F[m-1])/((F[m+1]-F[m-1])*(F[m]-F[m-1])));
                }
                else if  ((k>=F[m])&& (k<= F[m+1]))
                {
                    Hm[k] = (2*(F[m+1]-k)/((F[m+1]-F[m-1])*(F[m+1]-F[m])));
                }
                else if (k > F[m+1])
                {
                    Hm[k]=0;
                }
                T[m-1] +=  Xa[i][k] * Hm[k];
            }
            S[i][m-1] = log(T[m-1]);
        }
    }
    for (i=0; i<t;i++)
    {
        for (n=1; n<13; n++)
        {
            C[i][n]=0;
            for (m=0; m<M ; m++)
            {
                C[i][n] += S[i][m]*cos(Pi*n*(m+0.5)/13);
            }
        }
    }
}

void delta (double c[][cep], double de[][cep], int t)
{
    int i,j;
    for (j=2; j<(t-2); j++)
    {
        for (i=1; i<=13; i++)
        {
            de[j][i] = (2 * (c[j+2][i] - c[j-2][i]) + (c[j+1][i] - c[j-1][i]))/10;
        }
    }
}

int MFCC(double s[Fs*4],double MF[frame][mfccc+1])
{
    int i,j,t;
    double e[frame],a[frame][L],aw[frame][L],ai[frame][Num],ar[frame][Num],si[frame][Num],sr[frame][Num],c[frame][cep],de[frame][cep];

    t=framing(s,e,a);
    windowing(a,aw,t);
    for (i=0; i<t; i++)
    {
        for (j=0; j<Num; j++)
        {
            if (j<160)
                ar[i][j]=aw[i][j];
            else
                ar[i][j]=0;
        }
    }
    for (i=0; i<t; i++)
    {
        FFT(ar[i],ai[i],sr[i],si[i]);
    }
    Mel_fre(sr,si,c,t);
    for (i=0;i<t;i++)
    {
	c[i][13]=e[i];
    }
    delta(c,de,t);
/*    for (i=0; i<t; i++)
    {
        for (j=0; j<15; j++)
        {
                printf("%f ",de[i][j]);
        }
        printf("%d \n\n",i);
    }
*/  t=t-4;
    for (i=0; i<=t; i++)
    {
        for (j=0; j<=mfccc; j++)
        {
            MF[i][j]=0;
            if ((j>0)&&(j<=13))
                MF[i][j]=c[i+1][j];
            else if (j>13)
                MF[i][j]=de[i+1][j-13];
        }
    }
    MF[0][0]=t;
    return t;
}

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
    	int i,j,t,d,w;
    	double *s=(double *)calloc(Fs*4,sizeof(double));
	array_cb *cb=(array_cb *)calloc(W+1,sizeof(array_cb));
    	array_data *data=(array_data *)calloc(W+1,sizeof(array_data));
	for (w=1;w<=W;w++)
	{
		for (d=1;d<=doc;d++)
		{
    			for (i = 1; i < 32000; i++)
    			{
				s[i]=0;
        			s[0]=1;
        			s[i]=20+s[i-1];
    			}
    			t=MFCC(s,data[w][d]);
/*    			for (i=0; i<=t; i++)
    			{
        			for (j=0; j<=mfccc; j++)
        			{
					printf("%f ",data[d][i][j]);
				}
				printf("\n%d \n",i);
     			}
*/		}
		kmean(data[w],cb[w]);
	}
/*	for (w=1;w<=W;w++)
	{
		for (i=1;i<=Kmax;i++)
		{
			for (j=1;j<=mfccc;j++)
			{
				printf("%f ",cb[w][i][j]);
			}
			printf("\n");
		}
		printf("\n\n\n");
	}
*/	free(s);
	free(data);
}


