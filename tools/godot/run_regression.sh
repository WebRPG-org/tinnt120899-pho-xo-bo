#!/bin/bash
# Chay toan bo regression Godot (39 suite) + ghi ~/workspace/regression-move.log.
# Vong 10b: 2 test online can xu ly rieng — g4_online_server_test tu
# mo cong 18765 (FAIL neu cong ban), g4_online_server_probe can
# server that dang chay — nen chay server_test truoc (khong server),
# roi khoi server that chay probe, roi tat server.
# Dung: bash tools/godot/run_regression.sh
set -u
cd "$(dirname "$0")/../.." || exit 1
G=./tools/godot/Godot_v4.7.2-stable_linux.x86_64
LOG=~/workspace/regression-move.log
: > "$LOG"
ok=0; fail=0; failed=""
run_one() {
  local name="$1"
  local out rc
  out=$(timeout 120 "$G" --headless --path src/godot -s "res://tests/${name}.gd" 2>&1)
  rc=$?
  if [ $rc -eq 0 ]; then
    ok=$((ok+1)); echo "OK   $name :: $(echo "$out" | grep -E "PASS" | tail -1)" >> "$LOG"
  else
    fail=$((fail+1)); failed="$failed $name"
    echo "FAIL $name (exit $rc) :: " >> "$LOG"
    echo "$out" | grep -E "FAIL|TIMEOUT" | head -5 >> "$LOG"
  fi
}
for t in artpass_test g1_playtest g1_selftest g2_economy_education_test g2_hotspot_test g2_inventory_crafting_test g2_jobs_test g2_marketbattle_test g2_online_test g2_phonehub_test g2_savecloud_test g2_selftest g2_social_titles_story_test g2_tools_test g2_ui_wiring2_test g2_ui_wiring_test g3_playtest g4_artpass3_test g4_artpass4_test g4_artpass5_test g4_artpass7_test g4_artpass8_test g4_battle_ai_test g4_battle_anim_test g4_battle_hold_benefits_test g4_battle_main_test g4_battle_names_test g4_battle_save_test g4_battle_scene_test g4_coord_wasd_test g4_debug_toggle_test g4_dpad_test g4_move_input_test g4_online_ws_client_test g4_polish_test g4_r11_dbg_test v6_geometry_probe v6_overlay_test; do
  run_one "$t"
done
# Online: server_test tu mo cong (khong server nao dang chay).
run_one g4_online_server_test
# Probe: can server that.
"$G" --headless --path src/godot -s res://server/server_main.gd -- --port 18765 > /tmp/pxb_server_reg.log 2>&1 &
SRV=$!
sleep 6
out=$(timeout 120 "$G" --headless --path src/godot -s res://tests/g4_online_server_probe.gd -- --port 18765 --player-id probe-a --name "Probe A" --chat "hello" 2>&1)
kill $SRV 2>/dev/null
if echo "$out" | grep -q "PROBE OK"; then
  ok=$((ok+1)); echo "OK   g4_online_server_probe :: PROBE OK" >> "$LOG"
else
  fail=$((fail+1)); failed="$failed g4_online_server_probe"
  echo "FAIL g4_online_server_probe :: " >> "$LOG"
  echo "$out" | tail -3 >> "$LOG"
fi
echo "REGRESSION: $ok OK, $fail FAIL:$failed" >> "$LOG"
echo "REGRESSION: $ok OK, $fail FAIL:$failed"
