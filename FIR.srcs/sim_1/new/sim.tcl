##set x 4
#set time_i 800
#for {set x 0} {$x < 8} {incr x 1} {

# # postavljanje hijerarhijske putanje do signala nad kojim vrši forsiranje
# set force_path {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master($x)\/other_macs/sec_o}
# #append force_path }

# #postavljanje vremenskog trenutka u kome je potrebno izvršiti forsiranje vrednosti
# set time_c $time_i
# set time_string [append time_c ns}]
# #append time_string }


# #postavljanje vremenskog trenutka u kome treba prekinuti forsiranje vrednosti
# set cancel_f_time [expr {$time_i + 1000}]
# append cancel_f_time ns

# # forsiranje vrednost
# add_force $force_path -radix hex {0 $time_string -cancel_after $cancel_f_time

# # Uvećavanje vrednosti time_i za 400.
# incr time_i 100
#}
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(0)\/other_macs/sec_o} -radix hex {0 2020ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(1)\/other_macs/sec_o} -radix hex {0 2100ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(2)\/other_macs/sec_o} -radix hex {0 2200ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(3)\/other_macs/sec_o} -radix hex {0 2300ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(4)\/other_macs/sec_o} -radix hex {0 2400ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(5)\/other_macs/sec_o} -radix hex {0 2500ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(6)\/other_macs/sec_o} -radix hex {0 2600ns} -cancel_after 3000ns
add_force {/tb/uut_fir_filter/\other_sections(16)\/\other_macs_master(7)\/other_macs/sec_o} -radix hex {0 2700ns} -cancel_after 3000ns
