// SPDX-License-Identifier: MIT
/*
                                                                     ***                                                                    
                                                                ************                                                                
                                                            ********************,                                                           
                                                        *****************************                                                       
                                                   ,*************************************                                                   
                                               **********************************************,                                              
                                           *******************************************************                                          
                                      .***************************************************************                                      
                                   ,*****************************(%%%%%%%%%/*****************************                                   
                                   ,,,,,,*******************%%%%%%%%%%%%%%%%%%%%%*******************,,,,,                                   
                                   ,,,,,,,,,,***********(%%%%%%%%%%%%%%%%%%%%%%%%%%%(((((((*****,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,*****%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(((((//,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,/%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(///////,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,*******%%%%%%%%%%%%%%%%%%%%%%%%%((((((/////,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,***********%%%%%%%%%%%%%%%%#(((((((((((//,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,****************(%%%%%%%#(((((((((((((((/,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,********************(((((((((((((((((((((,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,********************((((((((((((((((((((*,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,*******************((((((((((((((((((((,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,******************(((((((((((((((((((,,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,*****************((((((((((((((((((,,,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,,,***************((((((((((((((((,,,,,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,,,,,*************((((((((((((((,,,,,,,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,,,,,,,,,*********((((((((((,,,,,,,,,,,,,,,,,,,,,,,,,                                   
                                   ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/**,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                                   
                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                                       
                                            ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                                           
                                                ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.                                               
                                                     ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                                                    
                                                         ,,,,,,,,,,,,,,,,,,,,,,,,,,,                                                        
                                                             ,,,,,,,,,,,,,,,,,,,                                                            
                                                                  ,,,,,,,,,                                                                 
                                                                      ,                                                                     
                                                                                                                                            
                                                                                                                                            
                                                                                                                                            
                                                                                                                                            
                                                                                           ........                                         
                                                                                           ........                                         
            ........    .....                 ......           ........    .....         ..............           ......                    
            .....................        ................      .....................     ..............      ................               
            ......................     ....................    .......................   ..............    ....................             
            .........     .........   ........      ........   .........      .........    ........       ........      ........            
            ........       ........   ......................   ........        ........    ........      ........        ........           
            ........       ........   ......................   ........        ........    ........      .........       ........           
            ........       ........   ........                 ..........    .........     ........       .........    .........            
            ........       ........     ...................    ......................       ...........    ....................             
            ........       ........       ..............       ........ ............         ..........      ................               
                                                               ........                                                                     
                                                               ........                                                                     
                                                               ........                                                                     
                                                               ........                                                                     
                                                               ........
*/
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./Ownable.sol";
contract NEPTO is Ownable, ERC20 {
    constructor(uint256 initialSupply) ERC20("Nepto", "NPTO") {
        _mint(msg.sender, initialSupply);
    }
}
