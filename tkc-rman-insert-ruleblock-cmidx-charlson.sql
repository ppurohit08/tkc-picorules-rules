CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

DECLARE
    rb          RMAN_RULEBLOCKS%ROWTYPE;


    

BEGIN
     

    
    -- BEGINNING OF RULEBLOCK --

    rb.blockid:='cmidx_charlson';
    
    DELETE FROM rman_ruleblocks WHERE blockid=rb.blockid;
    
    rb.picoruleblock:='
    
        /*  This is a algorithm to calculate the charlson comorbidity index  */
        
        #define_ruleblock([[rb_id]], {
                description: "This is a algorithm to calculate the charlson comorbidity index",
                is_active:2
        });
        
        #doc(,{
                txt:"disease entities"
        });
        
        mi => eadv.[icd_i21%,icd_i22%,icd_25_2].dt.exists();
        
        chf => eadv.[icd_i09_9, icd_i11_0, icd_i13_0, icd_i13_2,icd_i25_5,icd_i42_0, 
                    icd_i42_5,icd_i42_6,icd_i42_7,icd_i42_8,icd_i42_9,
                    icd_i43_%, icd_i50_%, icd_p29_0].dt.exists();
        
        pvd => eadv.[icd_i70_%, icd_i71_%, icd_i73_1, icd_i73_8, icd_i73_9, 
                    icd_i77_1, icd_i79_0, icd_i79_2, 
                    icd_k55_1, icd_k55_8, icd_k55_9, icd_z95_8, icd_z95_9].dt.exists();
                    
        cva => eadv.[icd_g45_%, icd_g46_%, icd_h34_%, icd_i6%].dt.exists();
        
        dem => eadv.[icd_f00_%,icd_f01_%,icd_f02_%,icd_f03_%, 
                    icd_f05_1, icd_g30_%, icd_g31_1].dt.exists();
                    
        cpd => eadv.[icd_i27_8, icd_i27_9, 
                    icd_j40_%,icd_j41_%,icd_j42_%,icd_j43_%,icd_j44_%,icd_j45_%,icd_j46_%,icd_j47_%,
                    icd_j60_%,icd_j61_%,icd_j62_%,icd_j63_%,icd_j64_%,icd_j65_%,icd_j66_%,icd_j67_%,
                    icd_j68_4, icd_j70_1, icd_j70_3].dt.exists();
                    
        rhe  => eadv.[icd_m05_%, icd_m06_%, icd_m31_5, 
                    icd_m32_%,icd_m33_%,icd_m34_%,
                    icd_m35_1, icd_m35_3, icd_m36_0].dt.exists();
                
        pud => eadv.[icd_k25_%,icd_k26_%,icd_k27_%,icd_k28_%,].dt.exists();
        
        mld => eadv.[icd_b18_%, icd_k70_0,icd_k70_1,icd_k70_2,icd_k70_3,icd_k70_9, 
                    icd_k71_3, icd_k71_4,icd_k71_5,icd_k71_7,
                    icd_k73_%, icd_k74_%, icd_k76_0, 
                    icd_k76_2,icd_k76_3,icd_k76_4,icd_k76_8,icd_k76_9,
                    icd_z94_4].dt.exists();
        
        sld => eadv.[icd_i85_0, icd_i85_9, icd_i86_4, icd_i98_2, 
                    icd_k70_4, icd_k71_1, icd_k72_1, icd_k72_9, 
                    icd_k76_5, icd_k76_6, icd_k76_7].dt.exists();
        
                    
        dmu => eadv.[icd_e10_0, icd_e10_1, icd_e10_6, icd_e10_8, icd_e10_9, 
                    icd_e11_0, icd_e11_1, icd_e11_6, icd_e11_8, icd_e11_9, 
                    icd_e12_0, icd_e12_1, icd_e12_6, icd_e12_8, icd_e12_9, 
                    icd_e13_0, icd_e13_1, icd_e13_6, icd_e13_8, icd_e13_9, 
                    icd_e14_0, icd_e14_1, icd_e14_6, icd_e14_8, icd_e14_9].dt.exists();
        
        
        dmc => eadv.[icd_e10_2, icd_e10_3, icd_e10_4, icd_e10_5, icd_e10_7, 
                    icd_e11_2, icd_e11_3, icd_e11_4, icd_e11_5, icd_e11_7, 
                    icd_e12_2, icd_e12_3, icd_e12_4, icd_e12_5, icd_e12_7, 
                    icd_e13_2, icd_e13_3, icd_e13_4, icd_e13_5, icd_e13_7, 
                    icd_e14_2, icd_e14_3, icd_e14_4, icd_e14_5, icd_e14_7].dt.exists();
                    
        plg => eadv.[icd_g04_1, icd_g11_4, icd_g80_1, icd_g80_2, icd_g81_%, icd_g82_%, 
                    icd_g83_0,icd_g83_1,icd_g83_2,icd_g83_3,icd_g83_4,icd_g83_9].dt.exists();
        
        ren => eadv.[icd_i12_0, icd_i13_1, 
                    icd_n03_2, icd_n03_3,icd_n03_4, icd_n03_5,icd_n03_6,icd_n03_7,
                    icd_n05_2,icd_n05_3,icd_n05_4,icd_n05_5,icd_n05_6,icd_n05_7,
                    icd_n18_%, icd_n19_%, icd_n25_0, 
                    icd_z49_0,icd_z49_1,icd_z49_2,icd_z94_0, icd_z99_2].dt.exists();
        
        ca => eadv.[icd_c%].dt.exists();
        
        met => eadv.[icd_c77_%,icd_c78_%,icd_c79_%,icd_c80_%].dt.exists();
        
        hiv => eadv.[icd_b20_%,icd_b21_%icd_b22_%,icd_b24_%].dt.exists();
        
        #doc(,{
                txt:"apply weights and sum"
        });
        
        dmc_w : { dmc!? => dmc * 2},{=>0};
        
        plg_w : { plg!? => plg * 2},{=>0};
        
        ren_w : { ren!? => ren * 2},{=>0};
        
        ca_w : { ca!? => ca * 2},{=>0};
        
        sld_w : { sld!? => sld * 3},{=>0};
        
        met_w : { met!? => met * 6},{=>0};
        
        hiv_w : { hiv!? => hiv * 6},{=>0};
        
        mi_w : { mi!? => mi * 1},{=>0};
        
        chf_w : { chf!? => chf * 1},{=>0};
        
        pvd_w : { pvd!? => pvd * 1},{=>0};
        
        cva_w : { cva!? => cva * 1},{=>0};
        
        dem_w : { dem!? => dem * 1},{=>0};
        
        cpd_w : { cpd!? => cpd * 1},{=>0};
        
        pud_w : { pud!? => pud * 1},{=>0};
        
        rhe_w : { rhe!? => rhe * 1},{=>0};
        
        mld_w : { mld!? => mld * 1},{=>0};
        
        dmu_w : { dmu!? => dmu * 1},{=>0};    
                    
        [[rb_id]] : { . => dmc_w + plg_w + ren_w + ca_w + sld_w + met_w + hiv_w + mi_w + 
                        chf_w + pvd_w + cva_w + dem_w + cpd_w +pud_w + rhe_w + mld_w + dmu_w },{=>0};
                        
        cci_cat : {cmidx_charlson >=4 =>3 },{cmidx_charlson >=2 => 2},{=>1};
        
        #define_attribute([[rb_id]],
            { 
                label: "Charlson comorbidity index"
            }
        );
        
        
    ';
    
    rb.picoruleblock := replace(rb.picoruleblock,'[[rb_id]]',rb.blockid);
    
    rb.picoruleblock:=rman_pckg.sanitise_clob(rb.picoruleblock);
    
    
    
    INSERT INTO rman_ruleblocks(blockid,picoruleblock) VALUES(rb.blockid,rb.picoruleblock);

        COMMIT;
    -- END OF RULEBLOCK --
END;







