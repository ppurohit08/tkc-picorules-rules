CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE
    rb          RMAN_RULEBLOCKS%ROWTYPE;


    

BEGIN

    
    
    
    -- BEGINNING OF RULEBLOCK --
    
        
    rb.blockid:='ckd_anaemia';
   
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Rule block to determine CKD complications */
        
        #define_ruleblock([[rb_id]],
            {
                description: "Rule block to determine CKD complications",
                is_active:2                
            }
        );
                
        #doc(,
            {
                txt:"Complications including Hb low",
                cite : "ckd_complications_ref1, ckd_complications_ref2"
            }
        );        
        
        ckd => rout_ckd.ckd.val.bind(); 
        
        rrt => rout_rrt.rrt.val.bind();
        
        esrd : {rrt in (1,2,4)=>1},{=>0};
        
        #doc(,
            {
                txt:"Haematenics"
            }
        );
        
        
        hb => eadv.lab_bld_hb._.lastdv().where(dt>sysdate-60);
        
        hb2 => eadv.lab_bld_hb._.lastdv().where(dt<hb_dt and dt>sysdate-90);
        
        hb3 => eadv.lab_bld_hb._.lastdv().where(dt<hb2_dt-21 and dt>sysdate-120);
        
        
        hb2_1_qt : { coalesce(hb2_val,0)>0 => round((hb_val-hb2_val)/hb2_val,2)};
        
        hb3_2_qt : { coalesce(hb3_val,0)>0 => round((hb2_val-hb3_val)/hb3_val,2)};
        
        hb_cum_qt : { hb2_1_qt > 0.2 and (hb3_2_qt + hb2_1_qt) >0.3 => 1},
                    { hb2_1_qt > 0.1 and (hb3_2_qt + hb2_1_qt) >0.2 => 2},
                    { hb2_1_qt < (-0.1) and (hb3_2_qt + hb2_1_qt) < (-0.2) => 3},
                    { hb2_1_qt < (-0.2) and (hb3_2_qt + hb2_1_qt) < (-0.3) => 4},
                    {=>0};
        
        hb_non_ss : {hb_dt - hb2_dt <7 and abs(hb2_1_qt)>0.2 =>1},{=>0};
        
        
        
        plt1 => eadv.lab_bld_platelets._.lastdv().where(dt>sysdate-60);
        
        wcc_neut1 => eadv.lab_bld_wcc_neutrophils._.lastdv().where(dt>sysdate-60);
        
        wcc_eos1 => eadv.lab_bld_wcc_eosinophils._.lastdv().where(dt>sysdate-60);
        
        
        
        rbc_mcv => eadv.lab_bld_rbc_mcv._.lastdv().where(dt>sysdate-60);
        
        esa => eadv.rxnc_b03xa._.lastdv().where( val=1);
        
        b05_ld => eadv.[rxnc_b05cb,rxnc_b05xa].dt.max().where(val=1);
        
        
        fer => eadv.lab_bld_ferritin._.lastdv().where(dt>sysdate-120);
        
        crp => eadv.lab_bld_crp._.lastdv().where(dt>sysdate-120);
        
        tsat1 => eadv.lab_bld_tsat._.lastdv().where(dt>sysdate-120);
        
        #doc(,{
                txt:"Determine haematenic complications"
        });
        
        
        hb_state : { coalesce(hb_val,0)>0 and coalesce(hb_val,0)<60 =>1},
                    { coalesce(hb_val,0)>=60 and coalesce(hb_val,0)<80 =>2},
                    { coalesce(hb_val,0)>=80 and coalesce(hb_val,0)<100 =>3},
                    { coalesce(hb_val,0)>=100 and coalesce(hb_val,0)<125 =>4},
                    { coalesce(hb_val,0)>=125 and coalesce(hb_val,0)<140 =>5},
                    { coalesce(hb_val,0)>=140 and coalesce(hb_val,0)<180 =>6},
                    { coalesce(hb_val,0)>180 =>7},
                    {=>0};
                    
        mcv_state : { hb_state=1 and coalesce(rbc_mcv_val,0)>0 and coalesce(rbc_mcv_val,0)<70 => 11 },
                    { hb_state=1 and coalesce(rbc_mcv_val,0)>=70 and coalesce(rbc_mcv_val,0)<80 => 12 },
                    { hb_state=1 and coalesce(rbc_mcv_val,0)>=80 and coalesce(rbc_mcv_val,0)<=100 => 20 },
                    { hb_state=1 and coalesce(rbc_mcv_val,0)>=100 => 31 },{ =>0};
                    
        fe_status_null : { fer_val? and tsat1_val? =>1},{=>0};
        
        fe_low : { fer_val<250 or tsat1_val<0.25=> 1},{=>0};
        
        hyper_ferr : { fer_val>1000 => 1},{=>0};
        
        thal_sig : {mcv_state=11 =>1 },{=>0};
        
        esa_null : { esa_dt? =>1},{=>0};
        
        esa_state : { esa_null=0 and esa_val=1 => 1},{ esa_null=0 and esa_val=0 => 2},{=>0};
        
        
                
        
        
        [[rb_id]] : { rrt in(1,2,4) or ckd>4 => 1 },{=>0};
        
        
        
        
        
    ';
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
    INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    COMMIT;
    -- END OF RULEBLOCK --
    
    
END;





