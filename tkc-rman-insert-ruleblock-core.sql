CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE
    rb          RMAN_RULEBLOCKS%ROWTYPE;


    

BEGIN
    
    -- BEGINNING OF RULEBLOCK --

    rb.blockid:='core_info_entropy';

    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Ruleblock to assess core information entropy */
        
        #define_ruleblock([[rb_id]],
            {
                description: "Ruleblock to assess core information entropy",
                
                is_active:2
                
            }
        );
        
        
        
         #doc(,
            {
                txt:"Get core information entropy"
            }
        );
       
        icpc_n => eadv.[icpc_%].dt.count();
        
        icd_n => eadv.[icd_%].dt.count();
        
        lab_n => eadv.[lab_%].dt.count();
        
        obs_n => eadv.[obs_%].dt.count();
        
        dmg_n => eadv.[dmg_%].dt.count();
        
        rxnc_n => eadv.[rxnc_%].dt.count();
        
        fd => eadv.[icd%,icpc%,lab%,rxnc%,obs%].dt.min();
        
        ld => eadv.[icd%,icpc%,lab%,rxnc%,obs%].dt.max();
        
        ts : { .=> round((ld-fd)/365,2)};
        
        icpc_d : { ts>0 => round(icpc_n/ts,2)};
        
        icd_d : { ts>0 => round(icd_n/ts,2)};
        
        lab_d : { ts>0 => round(lab_n/ts,2)};
        
        obs_d : { ts>0 => round(obs_n/ts,2)};
        
        dmg_d : { ts>0 => round(dmg_n/ts,2)};
        
        rxnc_d : { ts>0 => round(rxnc_n/ts,2)};
        
        icpc : { icpc_n>0 => 1},{=>0};
        
        icd : { icd_n>0 => 1},{=>0};
        
        lab : { lab_n>0 => 1},{=>0};
        
        obs : { obs_n>0 => 1},{=>0};
        
        rxnc : { rxnc_n>0 => 1},{=>0};
        
        
        
        core_info_entropy : { . => icpc + icd + lab  + rxnc + obs};
        
        #define_attribute(
            core_info_entropy,
            {
                label:"Core information entropy",
                desc:"Core information entropy",
                is_reportable:1,
                type:2
            }
        );
        
    ';
    
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);

    INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    
    -- END OF RULEBLOCK 
    
    
   
END;





