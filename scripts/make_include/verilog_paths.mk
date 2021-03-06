
ifndef D_ENGINE_REPO
$(error Please define D_ENGINE_REPO before including d-engine/make_include/verilog_paths.mk)
endif

D_ENGINE_ALL_VERILOG= \
$(D_ENGINE_REPO)/rtl/d_engine.sv \
$(D_ENGINE_REPO)/rtl/d_process.sv \
$(D_ENGINE_REPO)/rtl/vcordic.sv \
$(D_ENGINE_REPO)/rtl/reciprocal/hdl/reciprocal.v \
$(D_ENGINE_REPO)/rtl/elastic-buffer/eb15.sv

# seems these are duplicates from piston/hdl
#$(D_ENGINE_REPO)/rtl/reciprocal/hdl/*.v

