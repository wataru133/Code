#include<stdio.h>

void cong(int a[2],int b[2])
{
	int i;
	for (i=0;i<2;i++)
	{
		a[i]+=3;
		b[i]+=4;
	}
}
void main()
{
	int i;
	int a[2]={0,2},b[2]={1,4};
	cong(a,b);
	for (i=0;i<2;i++)
	{
		printf("%d %d\n",a[i],b[i]);
	}
}
