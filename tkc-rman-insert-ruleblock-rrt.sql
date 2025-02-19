CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE
    rb          RMAN_RULEBLOCKS%ROWTYPE;


    

BEGIN
     

    -- BEGINNING OF RULEBLOCK --
    
        
    rb.blockid:='rrt';

    
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Rule block to determine RRT status*/
        
        #define_ruleblock([[rb_id]],
            {
                description: "Rule block to determine RRT status",
                is_active:2
                
            }
        );

        #doc(,
            {
                txt : "Haemodialysis episode ICD proc codes and problem ICPC2p coding",
                cite : "rrt_hd_icd,rrt_pd_icd"
            }
        );
        hd_z49_n => eadv.icd_z49_1.dt.count();
        
        hd_131_n => eadv.[caresys_1310000].dt.count();
        
        hd_z49_1y_n => eadv.icd_z49_1.dt.count().where(dt>sysdate-365);
        
        hd_131_1y_n => eadv.[caresys_1310000].dt.count().where(dt>sysdate-365);
        
        /*
        hd_dt0 => eadv.[caresys_1310000,caresys_1310004, icpc_u59001,icpc_u59008,icd_z49_1,mbs_13105].dt.max(); 
        */
        
        mbs_13105_dt_max => eadv.mbs_13105.dt.max(); 
        
        mbs_13105_dt_min => eadv.mbs_13105.dt.min(); 
        
        hhd_op_enc_dt_min => eadv.enc_op_ren_hdp.dt.min();
        
        hhd_op_enc_dt_max => eadv.enc_op_ren_hdp.dt.max();
        
        hd_icpc_dt => eadv.[icpc_u59001,icpc_u59008].dt.max(); 
        
        hd_dt => eadv.icd_z49_1.dt.max(); 
        
        hd_dt_min => eadv.[caresys_1310000,icpc_u59001,icpc_u59008,icd_z49_1,mbs_13105].dt.min();
        
        #doc(,
            {   
                txt : "Peritoneal episode ICD and problem ICPC2p coding"
            }
        );
        
        pd_dt => eadv.[caresys_1310006,caresys_1310007,caresys_1310008,icpc_u59007,icpc_u59009,icd_z49_2].dt.max();
        
        pd_dt_min => eadv.[caresys_1310006,caresys_1310007,caresys_1310008,icpc_u59007,icpc_u59009,icd_z49_2].dt.min();
        
        pd_ex_dt => eadv.[caresys_1311000].dt.min();
        
        #doc(,
            {
                txt : "Transplant problem ICPC2p coding"
            }
        );
        tx_dt_icpc => eadv.icpc_u28001.dt.min();
        
        #doc(,
            {
                txt : "Transplant problem ICD coding"
            }
        );
        
        
        
        tx_dt_icd => eadv.icd_z94_0.dt.min();
        
        #doc(,{ 
            txt : "Handling muliparity based on intervening hd " 
        } );
                
        tx_dt_icd_last => eadv.icd_z94_0.dt.max();
        
        #doc(,{ 
            txt : "Number and last date of hd between transplant codes indicating graft failure and multi parity" 
        } );
        
        hd_tx_tx2_n => eadv.icd_z49_1.dt.count().where(dt between tx_dt_icd and tx_dt_icd_last );
        
        hd_tx_tx2_ld => eadv.icd_z49_1.dt.max().where(dt between tx_dt_icd and tx_dt_icd_last );
        
        #doc(,{ 
            txt : "Number of hd after last transplant indicating graft failure" 
        } );
        
        hd_tx2 => eadv.icd_z49_1.dt.count().where(dt > tx_dt_icd_last + 30 );
        
        tx_multi_fd => eadv.icd_z94_0.dt.min().where(dt > hd_tx_tx2_ld );
        
        tx_multi_flag : { hd_tx_tx2_n >10 =>1},{=>0};
        
        tx_multi_current : { tx_multi_flag =1 and coalesce(hd_tx2,0)=0 =>1},{=>0};        
        
        tx_dt : { . => least_date(tx_dt_icpc,tx_dt_icd)};
        
        tx_active : { tx_dt_icd_last!? and coalesce(hd_tx2,0)=0 =>1 },{=>0};
        
        #doc(,{
                txt : "Home-haemodialysis ICPC2p coding"
        });
        
        homedx_icpc_dt => eadv.[icpc_u59j99].dt.min();
        
        homedx_dt => eadv.[icpc_u59j99,enc_op_ren_hdp].dt.min();
        
        
        ren_enc => eadv.[enc_op%].dt.max();
        
        #doc(,
            {
                txt: "Determine RRT category based on chronology. RRT cat 1 [HD] requires more than 10 sessions within last year"
            }
        );
        
        /* adjusted switch order to catpure home haemo 18-08-21*/
        [[rb_id]]:{homedx_dt > nvl(greatest_date(hd_icpc_dt,pd_dt,tx_dt),lower__bound__dt) and tx_multi_current=0  => 4},
            {hd_dt > nvl(greatest_date(pd_dt,tx_dt,homedx_dt),lower__bound__dt) and (hd_z49_n>10 or hd_131_n>10) and tx_multi_current=0 and tx_active=0 => 1},
            {hd_icpc_dt > nvl(greatest_date(pd_dt,tx_dt,homedx_dt),lower__bound__dt) and coalesce(hd_dt,mbs_13105_dt_max)>sysdate-90 =>1},
            {pd_dt > nvl(greatest_date(hd_dt,tx_dt,homedx_dt),lower__bound__dt) and pd_dt>coalesce(pd_ex_dt,lower__bound__dt) and tx_multi_current=0 => 2},
            {tx_dt!? and tx_dt >= nvl(greatest_date(hd_dt,pd_dt,homedx_dt),lower__bound__dt) => 3},
            {tx_dt!? and tx_multi_current=1 => 3},
            {tx_active=1 => 3},
            {=>0};
        #doc(,
            {
                txt: "Generate binary variables for rrt categories"
            }
        );
        
        rrt_mm1 : { hd_dt<sysdate-90 =>1},{=>0};
            
        rrt_hd : {rrt=1 => 1},{=>0};
        
        rrt_pd : {rrt=2 => 1},{=>0};
        
        rrt_tx : {rrt=3 => 1},{=>0};
        
        rrt_hhd : {rrt=4 => 1},{=>0};
        
        rrt_hd_rsd : { mbs_13105_dt_max!?=> 1 },{=>0};
        
        rrt_hd_rsd_1y : { mbs_13105_dt_max > sysdate - 365 => 1 },{=>0};
        
        hd_incd : {hd_dt_min > sysdate-365 and hd_z49_n>=10 => 1},{=>0};
          
        pd_incd : {pd_dt_min > sysdate-365 => 1},{=>0};
        
        rrt_incd : { hd_incd=1 or pd_incd=1 => 1},{=>0};
        
        rrt_past :  {rrt=1 and coalesce(pd_dt,tx_dt,homedx_dt)!? => 1},
                    {rrt=2 and coalesce(hd_dt,tx_dt,homedx_dt)!? => 1},
                    {rrt=3 and coalesce(pd_dt,hd_dt,homedx_dt)!? => 1},
                    {rrt=4 and coalesce(hd_dt,tx_dt,pd_dt)!? => 1},
                    {rrt=0 and hd_icpc_dt!? =>1 },
                    {=>0};
        ;
        #doc(,{
                txt:"Satellite Hd recency"
        });
        
        hd_recent_flag : {mbs_13105_dt_max> sysdate-30 or hd_dt> sysdate-30 =>1},{=>0};
        
        #doc(,{
                txt:"Return to hd post tx or pd failures"
        });
        
        
        ret_hd_post_tx => eadv.icd_z49_1.dt.min().where(dt > tx_dt + 90);
        
        ret_hd_post_pd => eadv.icd_z49_1.dt.min().where(dt > pd_dt_min + 90);
        
        
        
        
        #doc(,{
                txt:"Current transplant patient based on 2y encounter activity"
        });
        
        
        
        tx_current : { rrt_tx=1 and ren_enc>sysdate-731 => 1 },{=>0};
        
        #define_attribute(
            [[rb_id]],
            {
                label:"Prevalent renal replacement therapy category [1=HD, 2=PD, 3=TX, 4=HHD]",
                desc:"Integer [1-4] where 1=HD, 2=PD, 3=TX, 4=HHD",
                is_reportable:0,
                type:2
            }
        );
        
        #define_attribute(
            rrt_hd,
            {
                label:"RRT Haemodialysis",
                is_reportable:1,
                type:2
            }
        );
        
         #define_attribute(
            rrt_pd,
            {
                label:"RRT Peritoneal dialysis",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            rrt_tx,
            {
                label:"RRT Renal transplant",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            rrt_hhd,
            {
                label:"RRT Home haemodialysis",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            hd_incd,
            {
                label:"Incident Haemodialysis",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            pd_incd,
            {
                label:"Incident Peritoneal dialysis",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            rrt_incd,
            {
                label:"Incident Peritoneal or haemodialysis",
                is_reportable:1,
                type:2
            }
        );
        
        #define_attribute(
            tx_multi_flag,
            {
                label:"Renal transplant multi-parity",
                is_reportable:1,
                type:2
            }
        );
    ';
    
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
   INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    -- END OF RULEBLOCK --
    
    -- BEGINNING OF RULEBLOCK --
    
        
    rb.blockid:='rrt_1_metrics';

    
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Rule block to determine RRT 1 metrics*/
        
        #define_ruleblock([[rb_id]],
            {
                description: "Rule block to determine RRT 1 metrics",
                is_active:2
                
            }
        );

        #doc(,
            {
                txt : "rrt session regularity"
            }
        );
        
        rrt => rout_rrt.rrt.val.bind();
        
        hd_ld => eadv.icd_z49_1.dt.max();
        
        hd_fd => eadv.icd_z49_1.dt.min();
        
        hd_n => eadv.icd_z49_1.dt.count();
        
        hd0_2w_f : { (sysdate - hd_ld)<14 => 1},{=>0};
        
        tspan : { . => hd_ld-hd_fd };
        
        tspan_y : { .=> round(tspan/365,1) };
        
        hd_oe : { tspan > 1 => round(100*(hd_n /tspan)/0.427,0)},{=>0};
        
        hd_tr => eadv.icd_z49_1.dt.temporal_regularity();
        
        hd_sl : { .=> round(hd_tr*100,0) };
        
        
        
        [[rb_id]] : {rrt=1 =>1};
        
       
    ';
    
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
   INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    -- END OF RULEBLOCK --
    
    
     -- BEGINNING OF RULEBLOCK --
    
        
    rb.blockid:='rrt_journey';

    
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /* Rule block to determine RRT 1 metrics*/
        
        #define_ruleblock([[rb_id]],
            {
                description: "Rule block to determine RRT 1 metrics",
                is_active:2
                
            }
        );

        #doc(,
            {
                txt : "rrt session regularity"
            }
        );
        
        rrt => rout_rrt.rrt.val.bind();
        
        hd_dt => eadv.icd_z49_1.dt.max();
        
        hd_dt_2w => eadv.icd_z49_1.dt.max().where(dt> sysdate-14);

        hd0_2w_f : { hd_dt_2w!? => 1},{=>0};
        
        hd_tr => eadv.icd_z49_1.dt.temporal_regularity();
        
        hd_clinic_ld => eadv.[enc_op_ren_nru,enc_op_med_rpc,enc_op_ren_wdd,enc_op_med_ksc,enc_op_ren_gpd,enc_op_ren_rsr].dt.max();
        
        
        [[rb_id]] : {. =>1};
        
        #define_attribute(
            rrt_hhd,
            {
                label:"RRT Home haemodialysis",
                is_reportable:1,
                type:2
            }
        );
    ';
    
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
   INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);
    
    -- END OF RULEBLOCK --
    
    
    
    
    
    
  
END;





