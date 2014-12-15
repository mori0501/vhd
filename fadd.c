#include <stdio.h>
#include <stdint.h>

uint32_t sign(uint32_t ui){
  return ui & (1u << 31);
}

uint32_t exp(uint32_t ui){
  return (ui >> 23) & 0xff;
}

uint32_t manti(uint32_t ui){
  return ui & 0x7fffff;
}

int is_NaN(uint32_t ui){
  if(exp(ui) == 0xff && manti(ui) != 0)
    return 1;
  return 0; 
}

int is_inf(uint32_t ui){
  if(exp(ui) == 0xff && manti(ui) == 0)
    return 1;
  return 0;
}

uint32_t naninf(uint32_t a,uint32_t b){
  if(is_NaN(a))
    return a;
  if(is_NaN(b))
    return b;
  if(is_inf(a) && is_inf(b)){
    if(sign(a)!=sign(b))
      return 0x7fc00000;
    return a;
  }
  if(is_inf(a))
    return a;
  return b;
}

uint32_t lrotate(uint32_t a,uint32_t u){
  if (u == 0){
    return a;
  }
  uint32_t temp = a >> 31;
  return lrotate(((a << 1) | temp),u-1);
} 

uint32_t fadd(uint32_t a,uint32_t b){
  // NaN,inf の処理
  if(exp(a) == 0xff || exp(b) == 0xff){
    return naninf(a,b);
  }
  //非正規化の処理 tekitou
  
  if(exp(a)==0)
    return b;
  if(exp(b)==0) 
    return a;
  if(exp(a) == 0 && exp(b) == 0)
    return 0;
  
  //絶対値の比較 aを大きい方とする,同じなら正の方を大きいとする
  //最上位ビットを０として大きさ比較
  uint32_t a0 = a & 0x7fffffff;
  uint32_t b0 = b & 0x7fffffff;
  uint32_t temp;
  if(a0 == b0){
    if(sign(a) == 1){
      temp = a;
      a = b;
      b = temp;
    }
  }
  else if(a0 < b0){
    temp = a;
    a = b;
     b = temp;
  }

  //1.mantissa00とする
  uint32_t ma = (1u << 25) | (manti(a) << 2);
  uint32_t mb = (1u << 25) | (manti(b) << 2);

  if(exp(a) - exp(b) > 25)
    mb = 0; //なくても大丈夫だけどvhdlのために
  else{
    //aのexpにbのexpをあわせたときのmbにする
    uint32_t i;
    for(i=0;i<exp(a)-exp(b);i++){
      mb = mb >> 1;
    }
  }
  uint32_t ea = exp(a);

  if(sign(a) == sign(b)){
    ma += mb;
    if((ma >> 26) == 1){
     ea++;
     ma = ma >> 1;
    }
  }
  else{
    ma -= mb;
    if (ma == 0) 
      return 0;   
    
    if((ma >> 24) == 1){
      ea--;
      ma <<= 1;
    }
    else if((ma >> 23) == 1){
      ea -= 2;
      ma <<= 2;
    }
    else if((ma >> 22) == 1){
      ea -= 3;
      ma <<= 3;
    }
    else if((ma >> 21) == 1){
      ea -= 4;
      ma <<= 4;
    } 
    else if((ma >> 20) == 1){
      ea -= 5;
      ma <<= 5;
    } 
    else if((ma >> 19) == 1){
      ea -= 6;
      ma <<= 6;
    } 
    else if((ma >> 18) == 1){
      ea -= 7;
      ma <<= 7;
    } 
    else if((ma >> 17) == 1){
      ea -= 8;
      ma <<= 8;
    } 
    else if((ma >> 16) == 1){
      ea -= 9;
      ma <<= 9;
    } 
    else if((ma >> 15) == 1){
      ea -= 10;
      ma <<= 10;
    } 
    else if((ma >> 14) == 1){
      ea -= 11;
      ma <<= 11;
    } 
    else if((ma >> 13) == 1){
      ea -= 12;
      ma <<= 12;
    } 
    else if((ma >> 12) == 1){
      ea -= 13;
      ma <<= 13;
    } 
    else if((ma >> 11) == 1){
      ea -= 14;
      ma <<= 14;
    } 
    else if((ma >> 10) == 1){
      ea -= 15;
      ma <<= 15;
    } 
    else if((ma >> 9) == 1){
      ea -= 16;
      ma <<= 16;
    } 
    else if((ma >> 8) == 1){
      ea -= 17;
      ma <<= 17;
    } 
    else if((ma >> 7) == 1){
      ea -= 18;
      ma <<= 18;
    } 
    else if((ma >> 6) == 1){
      ea -= 19;
      ma <<= 19;
    } 
    else if((ma >> 5) == 1){
      ea -= 20;
      ma <<= 20;
    } 
    else if((ma >> 4) == 1){
      ea -= 21;
      ma <<= 21;
    } 
    else if((ma >> 3) == 1){
      ea -= 22;
      ma <<= 22;
    } 
    else if((ma >> 2) == 1){
      ea -= 23;
      ma <<= 23;
    } 
    else if((ma >> 1) == 1){
      ea -= 24;
      ma <<= 24;
    } 
    else if((ma >> 0) == 1){
      ea -= 25;
      ma <<= 25;
    } 
    
    
    /*
    while((ma >> 25) == 0){
      ea--;
      ma <<= 1;
      }*/
  }
  //チェック
  if(ea == 0)
    return 0;
  if(ea >= 0xff)
    return sign(a) |0x7f800000;
  //maの最上位bitをなくす
  temp = lrotate(0xfffffffe,25);
  ma &= temp;
  //おわり
  return sign(a) | (ea << 23) | (ma >> 2);
}
