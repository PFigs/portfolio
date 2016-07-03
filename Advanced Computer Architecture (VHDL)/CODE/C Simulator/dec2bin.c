void dec2bin(int decimal, char *binary)
{
  int  k = 0, n = 0;
  int  neg_flag = 0;
  int  remain;
  int  old_decimal;
  char temp[80];
 
  if (decimal < 0)
  {      
    decimal = -decimal;
    neg_flag = 1;
  }
  do 
  {
    old_decimal = decimal;
    remain    = decimal % 2;
    
    decimal   = decimal / 2;
    
    /*printf("%d/2 = %d  remainder = %d\n", old_decimal, decimal, remain);*/
    
    temp[k++] = remain + '0';
  } while (decimal > 0);
 
  if (neg_flag)
    temp[k++] = '-';       
  else
    temp[k++] = ' ';       
 
  while (k >= 0)
    binary[n++] = temp[--k];
 
  binary[n-1] = 0;         
}
