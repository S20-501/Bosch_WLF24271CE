onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fsm_engine/clock
add wave -noupdate /fsm_engine/engine_frequency_s
add wave -noupdate /fsm_engine/engine_enabled_s
add wave -noupdate /fsm_engine/engine_max_speed_s
add wave -noupdate /fsm_engine/engine_acceleration_s
add wave -noupdate /fsm_engine/engine_acceleration_neg_sign_s
add wave -noupdate /fsm_engine/fsm_state
add wave -noupdate /fsm_engine/fsm_state_next
add wave -noupdate /fsm_engine/timer_counter
add wave -noupdate /fsm_engine/engine_speed
add wave -noupdate /fsm_engine/speed_disp_map
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8108 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 95
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4880 ps} {13970 ps}
