#!/bin/sh

BDT_DIR='Framework'

# Luadoc generation script for BDT

luadoc -d Doc \
	$BDT_DIR/BDT.lua \
\
	$BDT_DIR/BDT_GUI/BDT_GUI.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_Desk.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_Sheet.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_CallbackList.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_Color.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_SheetRenderer.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_SheetTextContent.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_SheetContent.lua \
	$BDT_DIR/BDT_GUI/BDT_GUI_Arrangement.lua \
\
	$BDT_DIR/BDT_Grob/BDT_Grob.lua \
	$BDT_DIR/BDT_Grob/BDT_Grob_Sprite.lua \
\
	$BDT_DIR/BDT_Turntable/BDT_Turntable.lua \
\
	$BDT_DIR/BDT_Undercart/BDT_Undercart.lua \
\
	$BDT_DIR/BDT_DebugConsole/BDT_DebugConsole.lua
