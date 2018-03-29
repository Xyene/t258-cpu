@echo off
python transpiler.py %1 > %1.a
python assembler.py %1.a