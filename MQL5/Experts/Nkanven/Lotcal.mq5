/ / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                               L o t C a l . m q 4   |  
 / / |                                               C o p y r i g h t   2 0 2 2 ,   N k o n d o g   A n s e l m e   V e n c e s l a s .   |  
 / / |                                                             h t t p s : / / w w w . l i n k e d i n / i n / n k o n d o g . c o m   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # p r o p e r t y   c o p y r i g h t   " C o p y r i g h t   2 0 2 2 ,   N k o n d o g   A n s e l m e   V e n c e s l a s . "  
 # p r o p e r t y   l i n k             " h t t p s : / / w w w . l i n k e d i n / i n / n k o n d o g . c o m   "  
 # p r o p e r t y   v e r s i o n       " 1 . 0 0 "  
 # p r o p e r t y   s t r i c t  
  
 / / P a r a m e t e r s  
 M q l T i c k   l a s t _ t i c k ;  
 / / E n u m e r a t i v e   f o r   t h e   b a s e   u s e d   f o r   r i s k   c a l c u l a t i o n  
 e n u m   E N U M _ R I S K _ B A S E  
     {  
       R I S K _ B A S E _ E Q U I T Y = 1 ,                 / / E Q U I T Y  
       R I S K _ B A S E _ B A L A N C E = 2 ,               / / B A L A N C E  
       R I S K _ B A S E _ F R E E M A R G I N = 3 ,         / / F R E E   M A R G I N  
       R I S K _ B A S E _ I N P U T = 4 ,                   / / I N P U T   B A S E  
     } ;  
  
 / / E n u m e r a t i v e   f o r   t h e   d e f a u l t   r i s k   s i z e  
 e n u m   E N U M _ R I S K _ D E F A U L T _ S I Z E  
     {  
       R I S K _ D E F A U L T _ F I X E D = 1 ,             / / F I X E D   S I Z E  
       R I S K _ D E F A U L T _ A U T O = 2 ,               / / A U T O M A T I C   S I Z E   B A S E D   O N   R I S K  
     } ;  
  
 i n p u t   E N U M _ R I S K _ D E F A U L T _ S I Z E   I n p R i s k D e f a u l t S i z e = R I S K _ D E F A U L T _ A U T O ;             / / P o s i t i o n   S i z e   M o d e  
 i n p u t   d o u b l e   I n p B a l a n c e = 1 0 0 0 0 . 0 ;                                                                                 / / B a l a n c e  
 d o u b l e   I n p D e f a u l t L o t S i z e = 0 . 0 1 ;                                                                         / / P o s i t i o n   S i z e   ( i f   f i x e d   o r   i f   n o   s t o p   l o s s   d e f i n e d )  
 i n p u t   E N U M _ R I S K _ B A S E   I n p R i s k B a s e = R I S K _ B A S E _ B A L A N C E ;                                           / / R i s k   B a s e  
 i n p u t   d o u b l e   I n p M a x R i s k P e r T r a d e = 0 . 5 ;                                                                         / / P e r c e n t a g e   T o   R i s k   E a c h   T r a d e  
 d o u b l e   I n p M i n L o t S i z e = 0 . 0 1 ;                                                                                 / / M i n i m u m   P o s i t i o n   S i z e   A l l o w e d  
 d o u b l e   I n p M a x L o t S i z e = 1 0 0 ;                                                                                   / / M a x i m u m   P o s i t i o n   S i z e   A l l o w e d  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                                                     |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 s t r i n g   S y m b   =   S y m b o l ( ) ;  
 d o u b l e   L o t S i z e = I n p D e f a u l t L o t S i z e ;  
 d o u b l e   p r i c e = 0 . 0 ;  
 d o u b l e   r i s k = 0 . 0 ;  
 d o u b l e   S t o p l o s s P i p s = 0 . 0 ;  
 / / T i c k V a l u e   i s   t h e   v a l u e   o f   t h e   i n d i v i d u a l   p r i c e   i n c r e m e n t   f o r   1   l o t   o f   t h e   i n s t r u m e n t ,   e x p r e s s e d   i n   t h e   a c c o u n t   c u r r e n t y  
 d o u b l e   T i c k V a l u e = S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ T R A D E _ T I C K _ V A L U E ) ;  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   E x p e r t   i n i t i a l i z a t i o n   f u n c t i o n                                                                       |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n I n i t ( )  
     {  
 / / - - -  
       P r i n t ( " T h e   E x p e r t   A d v i s o r   w i t h   n a m e   " , M Q L I n f o S t r i n g ( M Q L _ P R O G R A M _ N A M E ) , "   i s   r u n n i n g " ) ;  
 / / - - -   e n a b l e   o b j e c t   c r e a t e   e v e n t s  
       C h a r t S e t I n t e g e r ( C h a r t I D ( ) , C H A R T _ E V E N T _ O B J E C T _ C R E A T E , t r u e ) ;  
 / / - - -   e n a b l e   o b j e c t   d e l e t e   e v e n t s  
       C h a r t S e t I n t e g e r ( C h a r t I D ( ) , C H A R T _ E V E N T _ O B J E C T _ D E L E T E , t r u e ) ;  
 / / - - -  
       r e t u r n ( I N I T _ S U C C E E D E D ) ;  
     }  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                                                     |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n T i c k ( )  
     {  
       L o t S i z e C a l c u l a t e ( p r i c e ) ;  
 / / C o m m e n t ( " L o t   s i z e   :   " ,   L o t S i z e ) ;  
 d o u b l e   S t o p A m o u n t   =   S t o p l o s s P i p s   *   L o t S i z e   *   T i c k V a l u e ;  
  
       s t r i n g   t e x t   = " L o t   s i z e   f o r   " +   I n p M a x R i s k P e r T r a d e   + " %   =   "   +   D o u b l e T o S t r i n g ( L o t S i z e , 2 )   +   "   l o t   ( "   +   N o r m a l i z e D o u b l e ( S t o p A m o u n t ,   2 )   +   "   "   +   A c c o u n t I n f o S t r i n g ( A C C O U N T _ C U R R E N C Y )   +   " ) " ;  
       s t r i n g   n a m e   =   " L o t " ;  
       s t r i n g   n a m e 2   =   " r i s k " ;  
       O b j e c t C r e a t e ( 0 ,   n a m e ,   O B J _ L A B E L ,   0 ,   0 ,   0 ) ;  
       / / O b j e c t S e t T e x t ( n a m e , t e x t ,   3 6 ,   " C o r b e l   B o l d " ,   Y e l l o w G r e e n ) ;  
       O b j e c t S e t I n t e g e r ( 0 , n a m e ,   O B J P R O P _ C O R N E R ,   C O R N E R _ R I G H T _ U P P E R ) ;  
       O b j e c t S e t I n t e g e r ( 0 , n a m e ,   O B J P R O P _ X D I S T A N C E ,   5 5 0 ) ;  
       O b j e c t S e t I n t e g e r ( 0 , n a m e ,   O B J P R O P _ Y D I S T A N C E ,   1 0 ) ;  
       O b j e c t S e t S t r i n g ( 0 , n a m e , O B J P R O P _ T E X T , t e x t ) ;  
       O b j e c t S e t S t r i n g ( 0 , n a m e , O B J P R O P _ F O N T , " A r i a l " ) ;  
       O b j e c t S e t I n t e g e r ( 0 , n a m e , O B J P R O P _ F O N T S I Z E , 1 4 ) ;  
       O b j e c t S e t I n t e g e r ( 0 , n a m e , O B J P R O P _ C O L O R , c l r Y e l l o w G r e e n ) ;  
       / / L a b e l D e l e t e ( 0 ,   n a m e ) ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C h a r t E v e n t   f u n c t i o n                                                                                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n C h a r t E v e n t ( c o n s t   i n t   i d ,                   / /   E v e n t   i d e n t i f i e r  
                                     c o n s t   l o n g &   l p a r a m ,       / /   E v e n t   p a r a m e t e r   o f   l o n g   t y p e  
                                     c o n s t   d o u b l e &   d p a r a m ,   / /   E v e n t   p a r a m e t e r   o f   d o u b l e   t y p e  
                                     c o n s t   s t r i n g &   s p a r a m )   / /   E v e n t   p a r a m e t e r   o f   s t r i n g   t y p e  
     {  
 / / - - -   t h e   o b j e c t   h a s   b e e n   d e l e t e d  
       i f ( i d = = C H A R T E V E N T _ O B J E C T _ D E L E T E )  
           {  
             P r i n t ( " T h e   o b j e c t   w i t h   n a m e   " , s p a r a m , "   h a s   b e e n   d e l e t e d " ) ;  
           }  
 / / - - -   t h e   o b j e c t   h a s   b e e n   c r e a t e d  
       i f ( i d = = C H A R T E V E N T _ O B J E C T _ C R E A T E )  
           {  
             P r i n t ( " T h e   o b j e c t   w i t h   n a m e   " , s p a r a m , "   h a s   b e e n   c r e a t e d " ) ;  
           }  
  
 / / - - -   t h e   o b j e c t   h a s   b e e n   m o v e d   o r   i t s   a n c h o r   p o i n t   c o o r d i n a t e s   h a s   b e e n   c h a n g e d  
       i f ( i d = = C H A R T E V E N T _ O B J E C T _ D R A G )  
           {  
             p r i c e   =   O b j e c t G e t D o u b l e ( 0 ,   s p a r a m ,   O B J P R O P _ P R I C E ,   0 ) ;  
             P r i n t ( " T h e   a n c h o r   p o i n t   c o o r d i n a t e s   o f   t h e   o b j e c t   w i t h   n a m e   " , s p a r a m , "   h a s   b e e n   c h a n g e d .   P r i c e   " ,   p r i c e ) ;  
           }  
     }  
  
  
 / / L o t   S i z e   C a l c u l a t o r  
 v o i d   L o t S i z e C a l c u l a t e ( d o u b l e   s t o p L o s s )  
     {  
     S y m b o l I n f o T i c k ( _ S y m b o l , l a s t _ t i c k ) ;  
       d o u b l e   S L = 0 ;  
       d o u b l e   P r i c e A s k = l a s t _ t i c k . a s k ;  
       d o u b l e   P r i c e B i d = l a s t _ t i c k . b i d ;  
  
       i f ( s t o p L o s s   <   P r i c e A s k )  
           {  
             S L   =   ( P r i c e A s k - s t o p L o s s ) / _ P o i n t ;  
           }  
       i f ( s t o p L o s s   >   P r i c e A s k )  
           {  
             S L   =   ( s t o p L o s s - P r i c e B i d ) / _ P o i n t ;  
           }  
       P r i n t ( " S t o p   l o s s   d i s t a n c e   " ,   S L ) ;  
  
 / / I f   t h e   p o s i t i o n   s i z e   i s   d y n a m i c  
       i f ( I n p R i s k D e f a u l t S i z e = = R I S K _ D E F A U L T _ A U T O )  
           {  
             / / I f   t h e   s t o p   l o s s   i s   n o t   z e r o   t h e n   c a l c u l a t e   t h e   l o t   s i z e  
             i f ( S L ! = 0 )  
                 {  
                   d o u b l e   R i s k B a s e A m o u n t = 0 ;  
                   / / D e f i n e   t h e   b a s e   f o r   t h e   r i s k   c a l c u l a t i o n   d e p e n d i n g   o n   t h e   p a r a m e t e r   c h o s e n  
                   i f ( I n p R i s k B a s e = = R I S K _ B A S E _ B A L A N C E )  
                         R i s k B a s e A m o u n t = A c c o u n t I n f o D o u b l e ( A C C O U N T _ B A L A N C E ) ;  
                   i f ( I n p R i s k B a s e = = R I S K _ B A S E _ E Q U I T Y )  
                         R i s k B a s e A m o u n t = A c c o u n t I n f o D o u b l e ( A C C O U N T _ E Q U I T Y ) ;  
                   i f ( I n p R i s k B a s e = = R I S K _ B A S E _ F R E E M A R G I N )  
                         R i s k B a s e A m o u n t = A c c o u n t I n f o D o u b l e ( A C C O U N T _ F R E E M A R G I N ) ;  
                   i f ( I n p R i s k B a s e = = R I S K _ B A S E _ I N P U T )  
                       R i s k B a s e A m o u n t = I n p B a l a n c e ;  
                        
                   / / C a l c u l a t e   t h e   P o s i t i o n   S i z e  
                   / / P r i n t ( " R i s k B a s e A m o u n t   " ,   R i s k B a s e A m o u n t ,   "   M a x R i s k P e r T r a d e   " ,   I n p M a x R i s k P e r T r a d e ,   " S t o p   l o s s   " ,   S L ,   "   T i c k V a l u e   " ,   T i c k V a l u e ) ;  
  
                   L o t S i z e = ( ( R i s k B a s e A m o u n t * I n p M a x R i s k P e r T r a d e / 1 0 0 ) / ( S L * T i c k V a l u e ) ) ;  
                   S t o p l o s s P i p s   =   S L ;  
  
                 }  
             / / I f   t h e   s t o p   l o s s   i s   z e r o   t h e n   t h e   l o t   s i z e   i s   t h e   d e f a u l t   o n e  
             i f ( S L = = 0 )  
                 {  
                   L o t S i z e = I n p D e f a u l t L o t S i z e ;  
                 }  
           }  
 / / N o r m a l i z e   t h e   L o t   S i z e   t o   s a t i s f y   t h e   a l l o w e d   l o t   i n c r e m e n t   a n d   m i n i m u m   a n d   m a x i m u m   p o s i t i o n   s i z e  
       L o t S i z e = M a t h F l o o r ( L o t S i z e / S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ S T E P ) ) * S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ S T E P ) ;  
  
 / / L i m i t   t h e   l o t   s i z e   i n   c a s e   i t   i s   g r e a t e r   t h a n   t h e   m a x i m u m   a l l o w e d   b y   t h e   u s e r  
       i f ( L o t S i z e > I n p M a x L o t S i z e )  
             L o t S i z e = I n p M a x L o t S i z e ;  
 / / L i m i t   t h e   l o t   s i z e   i n   c a s e   i t   i s   g r e a t e r   t h a n   t h e   m a x i m u m   a l l o w e d   b y   t h e   b r o k e r  
       i f ( L o t S i z e > S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ M A X ) )  
             L o t S i z e = S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ M A X ) ;  
       P r i n t ( " L o t   " ,   L o t S i z e ,   "   M a x   l o t   " ,   S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ M A X ) ) ;  
 / / I f   t h e   l o t   s i z e   i s   t o o   s m a l l   t h e n   s e t   i t   t o   0   a n d   d o n ' t   t r a d e  
       i f ( L o t S i z e   <   S y m b o l I n f o D o u b l e ( S y m b , S Y M B O L _ V O L U M E _ M I N ) )  
           {  
             L o t S i z e = 0 ;  
             P r i n t ( " L o t   s i z e   t o o   s m a l l " ) ;  
           }  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   D e l e t e   a   t e x t   l a b e l                                                                                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   L a b e l D e l e t e ( c o n s t   l o n g       c h a r t _ I D = 0 ,       / /   c h a r t ' s   I D  
                                   c o n s t   s t r i n g   n a m e = " L a b e l " )   / /   l a b e l   n a m e  
     {  
 / / - - -   r e s e t   t h e   e r r o r   v a l u e  
       R e s e t L a s t E r r o r ( ) ;  
 / / - - -   d e l e t e   t h e   l a b e l  
       i f ( ! O b j e c t D e l e t e ( c h a r t _ I D , n a m e ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   d e l e t e   a   t e x t   l a b e l !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
 / / - - -   s u c c e s s f u l   e x e c u t i o n  
       r e t u r n ( t r u e ) ;  
     } 