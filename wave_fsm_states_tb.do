onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fsm_states_tb/temperature_s
add wave -noupdate /fsm_states_tb/engine_acceleration_s
add wave -noupdate /fsm_states_tb/sinking_led_s
add wave -noupdate /fsm_states_tb/sink_button_s
add wave -noupdate /fsm_states_tb/temperature_button_s
add wave -noupdate /fsm_states_tb/speed_s
add wave -noupdate /fsm_states_tb/clock
add wave -noupdate /fsm_states_tb/end_led_s
add wave -noupdate /fsm_states_tb/washing_led_s
add wave -noupdate /fsm_states_tb/sink_s
add wave -noupdate /fsm_states_tb/time_divider_s
add wave -noupdate /fsm_states_tb/start_s
add wave -noupdate /fsm_states_tb/engine_acceleration_neg_sign_s
add wave -noupdate /fsm_states_tb/sink_led_s
add wave -noupdate /fsm_states_tb/start_button_s
add wave -noupdate /fsm_states_tb/start_led_s
add wave -noupdate /fsm_states_tb/speed_button_s
add wave -noupdate /fsm_states_tb/fsm_prg_sink_enabled_s
add wave -noupdate /fsm_states_tb/sevenseg_value_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {97023 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 216
configure wave -valuecolwidth 65
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
WaveRestoreZoom {70075 ps} {101575 ps}
