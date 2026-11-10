@echo off
rem Quick start: checks the tools, copies your CD's MARIO folder, lifts, builds,
rem and leaves a shortcut here. See README "Getting Started". Safe to run again.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\setup.ps1" %*
