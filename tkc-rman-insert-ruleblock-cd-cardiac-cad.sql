CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE
    rb          RMAN_RULEBLOCKS%ROWTYPE;


    

BEGIN
    
   
    -- BEGINNING OF RULEBLOCK --

    rb.blockid:='cd_cardiac_cad';

    
    
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Algorithm to assess cardiac disease  */
        
        #define_ruleblock(cd_cardiac_cad,
            {
                description: "Algorithm to assess cardiac disease",
                is_active:2
                
            }
        );
        
            
        
            #doc(,
                {
                    section:"CAD"
                }
            );
            #doc(,
                {
                    txt:"first date of coronary insufficiency based on coding (ICD and ICPC)"
                }
            );    
            
            
            
            cabg => eadv.[icd_z95_1,icpc_k54007].dt.min();
            
            
            
            #doc(,
                {
                    txt:"first date of type 2 AMI (not implemented as codes non-existent)"
                }
            );   
            
            /* mi_type2_icd => eadv.icd_i21_a1.dt.min(); */
            
            #doc(,
                {
                    txt:"first and last dates of AMI inclusive of NSTEMI and STEMI and subsequent"
                }
            );  
            
            nstemi_fd_icd => eadv.[icd_i21_4,icd_i22_2].dt.min();
            
            nstemi_fd_icpc => eadv.icpc_k75016.dt.min();        
            
            nstemi_fd : {. => least_date(nstemi_fd_icd,nstemi_fd_icpc)};
            
            stemi_fd_icd => eadv.[icd_i21_0,icd_i21_1,icd_i21_2,icd_i21_3,icd_i22_0,icd_i22_1,icd_i22_8,icd_i22_9].dt.min();
            
            stemi_fd_icpc => eadv.icpc_k75015.dt.min();
            
            stemi_fd : {. => least_date(stemi_fd_icd,stemi_fd_icpc)};
        
            nstemi_ld => eadv.[icpc_k75016,icd_i21_4,icd_i22_2].dt.max().where(dt > nstemi_fd);
            
            stemi_ld => eadv.[icpc_k75015,icd_i21_0,icd_i21_1,icd_i21_2,icd_i21_3,icd_i22_0,icd_i22_1,icd_i22_8,icd_i22_9].dt.max().where(dt > stemi_fd);
            
            ami_icd_null : {coalesce(stemi_fd_icd,nstemi_fd_icd)? => 1};
            
            #doc(,
                {
                    txt:"STEMI vascular region"
                }
            );  
            stemi_anat_0 => eadv.[icd_i21_0,icd_i21_1,icd_i21_2,icd_i21_3].att.first();
            
            stemi_anat : { stemi_anat_0!? => to_number(substr(stemi_anat_0,-1))+1};
            
            #doc(,
                {
                    txt:"AMI complication"
                }
            );
            
            ami_i23 => eadv.[icd_i23].dt.max();
            
            ami : { coalesce(stemi_fd,nstemi_fd,stemi_ld,nstemi_ld,ami_i23)!? => 1},{=>0};
            
            #doc(,
                {
                    txt:"Coronary ischaemia other than AMI"
                }
            );
            
            cad_chronic_icd => eadv.[icd_i24%,icd_i25%].dt.min();
            
            cad_ihd_icpc => eadv.[icpc_k74%,icpc_k76%].dt.min();        
                
            cad_ex_ami :{ coalesce(cad_chronic_icd,cad_ihd_icpc)!? =>1},{=>0};   
            
            cad_fd : { . => least_date(cad_ihd_icpc,cad_chronic_icd)};
            
            cad_prev : { cad_fd!? => 1 },{=>0};
        
            cad_incd : { cad_fd > sysdate - 365 => 1},{=>0};
            
            cad : { greatest(ami,cad_ex_ami)>0 or cabg!? =>1 },{=>0};
            
            
            
            #doc(,
                {
                    section:"other CVD"
                }
            );
            
            #doc(,
                {
                    txt:"Other atherosclerotic disease"
                }
            );   
            
            
            cva_dt => eadv.[icd_g46%,icpc_k89%,icpc_k90%,icpc_k91%].dt.min();
            
            pvd_dt => eadv.[icd_i70%,icd_i71%,icd_i72%,icd_i73%,icpc_k92%].dt.min();
           
            cva : { cva_dt!? =>1},{=>0};
           
            pvd : { pvd_dt!? =>1},{=>0};
            
            
            
            #doc(,
                {
                    txt:"Medication"
                }
            ); 
            
            #doc(,
                {
                    txt: "antiplatelet agents"
                }
            ); 
            
            
            rxn_ap => eadv.[rxnc_b01ac].dt.min().where(val=1);
            
            
            #doc(,
                {
                    txt: "anti-coagulation including NOAC"
                }
            ); 
            
            
            rxn_anticoag => eadv.[rxnc_b01aa,rxnc_b01af,rxnc_b01ae,rxnc_b01ab].dt.min().where(val=1);
            
            #doc(,
                {
                    txt: "beta blockers"
                }
            ); 
            
        
            rxn_bb_ag => eadv.rxnc_c07ag.dt.min().where(val=1);
            
            rxn_bb_aa => eadv.rxnc_c07aa.dt.min().where(val=1);
            
            rxn_bb_ab => eadv.rxnc_c07ab.dt.min().where(val=1);
            
            rxn_bb : {. => least_date(rxn_bb_ag,rxn_bb_aa,rxn_bb_ab)};
            
            #doc(,
                {
                    txt: "RAAS blockers"
                }
            ); 
            
            rxn_ace_aa => eadv.rxnc_c09aa.dt.min().where(val=1);
            
            rxn_arb_aa => eadv.rxnc_c09ca.dt.min().where(val=1);
            
            rxn_raas : {. => least_date(rxn_ace_aa, rxn_arb_aa)};
            
            #doc(,
                {
                    txt: "lipid lowering"
                }
            ); 
            
            rxn_statin => eadv.[rxnc_c10aa,rxnc_c10bx,rxnc_c10ba].dt.min().where(val=1);
            
            rxn_c10_ax => eadv.rxnc_c10_ax.dt.min().where(val=1);
           
            rxn : {coalesce(rxn_ap,rxn_anticoag,rxn_bb,rxn_raas,rxn_statin,rxn_c10_ax)!? =>1};
            
            #doc(,
                {
                    txt: "Investigations"
                }
            ); 
            
            echo_ld => rout_cd_cardiac_ix.echo_ld.val.bind();
            
            cardang_ld => rout_cd_cardiac_ix.cardang_ld.val.bind();
            
             /* NT cardiac report hot linking*/
            cardang_l => eadv.[ntc_rep_cangio]._.lastdv();
            
            cd_cardiac_cad : {cad=1 =>1},{=>0};
            
            #define_attribute(
            cd_cardiac_cad,
                {
                    label:"Coronary artery disease",
                    desc:"Presence of Coronary artery disease",
                    is_reportable:1,
                    type:2
                }
            );
        
    ';
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
    INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    COMMIT;
    -- END OF RULEBLOCK --
   
    
   
END;





