; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

declare half @llvm.fabs.f16(half)
declare double @llvm.fabs.f64(double)
declare <2 x float> @llvm.fabs.v2f32(<2 x float>)

define i1 @test1(float %x, float %y) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %ext1 = fpext float %x to double
  %ext2 = fpext float %y to double
  %cmp = fcmp ogt double %ext1, %ext2
  ret i1 %cmp
}

define i1 @test2(float %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[A:%.*]], 1.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %ext = fpext float %a to double
  %cmp = fcmp ogt double %ext, 1.000000e+00
  ret i1 %cmp
}

define i1 @test3(float %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[EXT:%.*]] = fpext float [[A:%.*]] to double
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt double [[EXT]], 0x3FF0000000000001
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %ext = fpext float %a to double
  %cmp = fcmp ogt double %ext, 0x3FF0000000000001 ; more precision than float.
  ret i1 %cmp
}

define i1 @test4(float %a) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[EXT:%.*]] = fpext float [[A:%.*]] to double
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt double [[EXT]], 0x36A0000000000000
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %ext = fpext float %a to double
  %cmp = fcmp ogt double %ext, 0x36A0000000000000 ; denormal in float.
  ret i1 %cmp
}

define i1 @fneg_constant_swap_pred(float %x) {
; CHECK-LABEL: @fneg_constant_swap_pred(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt float [[X:%.*]], -1.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %neg = fsub float -0.0, %x
  %cmp = fcmp ogt float %neg, 1.0
  ret i1 %cmp
}

define <2 x i1> @fneg_constant_swap_pred_vec(<2 x float> %x) {
; CHECK-LABEL: @fneg_constant_swap_pred_vec(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt <2 x float> [[X:%.*]], <float -1.000000e+00, float -2.000000e+00>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %neg = fsub <2 x float> <float -0.0, float -0.0>, %x
  %cmp = fcmp ogt <2 x float> %neg, <float 1.0, float 2.0>
  ret <2 x i1> %cmp
}

define <2 x i1> @fneg_constant_swap_pred_vec_undef(<2 x float> %x) {
; CHECK-LABEL: @fneg_constant_swap_pred_vec_undef(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt <2 x float> [[X:%.*]], <float -1.000000e+00, float -2.000000e+00>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %neg = fsub <2 x float> <float undef, float -0.0>, %x
  %cmp = fcmp ogt <2 x float> %neg, <float 1.0, float 2.0>
  ret <2 x i1> %cmp
}

define i1 @fneg_fneg_swap_pred(float %x, float %y) {
; CHECK-LABEL: @fneg_fneg_swap_pred(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %neg1 = fsub float -0.0, %x
  %neg2 = fsub float -0.0, %y
  %cmp = fcmp olt float %neg1, %neg2
  ret i1 %cmp
}

define <2 x i1> @fneg_fneg_swap_pred_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @fneg_fneg_swap_pred_vec(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %neg1 = fsub <2 x float> <float -0.0, float -0.0>, %x
  %neg2 = fsub <2 x float> <float -0.0, float -0.0>, %y
  %cmp = fcmp olt <2 x float> %neg1, %neg2
  ret <2 x i1> %cmp
}

define <2 x i1> @fneg_fneg_swap_pred_vec_undef(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @fneg_fneg_swap_pred_vec_undef(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %neg1 = fsub <2 x float> <float -0.0, float undef>, %x
  %neg2 = fsub <2 x float> <float undef, float -0.0>, %y
  %cmp = fcmp olt <2 x float> %neg1, %neg2
  ret <2 x i1> %cmp
}

define i1 @test7(float %x) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %ext = fpext float %x to ppc_fp128
  %cmp = fcmp ogt ppc_fp128 %ext, 0xM00000000000000000000000000000000
  ret i1 %cmp
}

define float @test8(float %x) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    [[CONV2:%.*]] = uitofp i1 [[CMP]] to float
; CHECK-NEXT:    ret float [[CONV2]]
;
  %conv = fpext float %x to double
  %cmp = fcmp olt double %conv, 0.000000e+00
  %conv1 = zext i1 %cmp to i32
  %conv2 = sitofp i32 %conv1 to float
  ret float %conv2
; Float comparison to zero shouldn't cast to double.
}

define i1 @fabs_uge(double %a) {
; CHECK-LABEL: @fabs_uge(
; CHECK-NEXT:    ret i1 true
;
  %call = call double @llvm.fabs.f64(double %a)
  %cmp = fcmp uge double %call, 0.0
  ret i1 %cmp
}

define i1 @fabs_olt(half %a) {
; CHECK-LABEL: @fabs_olt(
; CHECK-NEXT:    ret i1 false
;
  %call = call half @llvm.fabs.f16(half %a)
  %cmp = fcmp olt half %call, 0.0
  ret i1 %cmp
}

define <2 x i1> @fabs_ole(<2 x float> %a) {
; CHECK-LABEL: @fabs_ole(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq <2 x float> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %call = call <2 x float> @llvm.fabs.v2f32(<2 x float> %a)
  %cmp = fcmp ole <2 x float> %call, zeroinitializer
  ret <2 x i1> %cmp
}

define i1 @fabs_ogt(double %a) {
; CHECK-LABEL: @fabs_ogt(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp one double [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = call double @llvm.fabs.f64(double %a)
  %cmp = fcmp ogt double %call, 0.0
  ret i1 %cmp
}

define i1 @fabs_oge(double %a) {
; CHECK-LABEL: @fabs_oge(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ord double [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = call double @llvm.fabs.f64(double %a)
  %cmp = fcmp oge double %call, 0.0
  ret i1 %cmp
}

define i1 @fabs_une(half %a) {
; CHECK-LABEL: @fabs_une(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp une half [[A:%.*]], 0xH0000
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = call half @llvm.fabs.f16(half %a)
  %cmp = fcmp une half %call, 0.0
  ret i1 %cmp
}

define i1 @fabs_oeq(double %a) {
; CHECK-LABEL: @fabs_oeq(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq double [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = call double @llvm.fabs.f64(double %a)
  %cmp = fcmp oeq double %call, 0.0
  ret i1 %cmp
}

define i1 @fabs_one(double %a) {
; CHECK-LABEL: @fabs_one(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp one double [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %call = call double @llvm.fabs.f64(double %a)
  %cmp = fcmp one double %call, 0.0
  ret i1 %cmp
}

define <2 x i1> @fabs_ueq(<2 x float> %a) {
; CHECK-LABEL: @fabs_ueq(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ueq <2 x float> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %call = call <2 x float> @llvm.fabs.v2f32(<2 x float> %a)
  %cmp = fcmp ueq <2 x float> %call, zeroinitializer
  ret <2 x i1> %cmp
}

; Don't crash.
define i32 @test17(double %a, double (double)* %p) {
; CHECK-LABEL: @test17(
; CHECK-NEXT:    [[CALL:%.*]] = tail call double [[P:%.*]](double [[A:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ueq double [[CALL]], 0.000000e+00
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %call = tail call double %p(double %a)
  %cmp = fcmp ueq double %call, 0.000000e+00
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Can fold fcmp with undef on one side by choosing NaN for the undef
define i32 @test18_undef_unordered(float %a) {
; CHECK-LABEL: @test18_undef_unordered(
; CHECK-NEXT:    ret i32 1
;
  %cmp = fcmp ueq float %a, undef
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}
; Can fold fcmp with undef on one side by choosing NaN for the undef
define i32 @test18_undef_ordered(float %a) {
; CHECK-LABEL: @test18_undef_ordered(
; CHECK-NEXT:    ret i32 0
;
  %cmp = fcmp oeq float %a, undef
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Can fold fcmp with undef on both side
;   fcmp u_pred undef, undef -> true
;   fcmp o_pred undef, undef -> false
; because whatever you choose for the first undef
; you can choose NaN for the other undef
define i1 @test19_undef_unordered() {
; CHECK-LABEL: @test19_undef_unordered(
; CHECK-NEXT:    ret i1 true
;
  %cmp = fcmp ueq float undef, undef
  ret i1 %cmp
}

define i1 @test19_undef_ordered() {
; CHECK-LABEL: @test19_undef_ordered(
; CHECK-NEXT:    ret i1 false
;
  %cmp = fcmp oeq float undef, undef
  ret i1 %cmp
}

; Can fold 1.0 / X < 0.0 --> X < 0 with ninf
define i1 @test20_recipX_olt_0(float %X) {
; CHECK-LABEL: @test20_recipX_olt_0(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf olt float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float 1.0, %X
  %cmp = fcmp ninf olt float %div, 0.0
  ret i1 %cmp
}

; Can fold -2.0 / X <= 0.0 --> X >= 0 with ninf
define i1 @test21_recipX_ole_0(float %X) {
; CHECK-LABEL: @test21_recipX_ole_0(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf oge float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float -2.0, %X
  %cmp = fcmp ninf ole float %div, 0.0
  ret i1 %cmp
}

; Can fold 2.0 / X > 0.0 --> X > 0 with ninf
define i1 @test22_recipX_ogt_0(float %X) {
; CHECK-LABEL: @test22_recipX_ogt_0(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf ogt float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float 2.0, %X
  %cmp = fcmp ninf ogt float %div, 0.0
  ret i1 %cmp
}

; Can fold -1.0 / X >= 0.0 --> X <= 0 with ninf
define i1 @test23_recipX_oge_0(float %X) {
; CHECK-LABEL: @test23_recipX_oge_0(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf ole float [[X:%.*]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float -1.0, %X
  %cmp = fcmp ninf oge float %div, 0.0
  ret i1 %cmp
}

; Do not fold 1.0 / X > 0.0 when ninf is missing
define i1 @test24_recipX_noninf_cmp(float %X) {
; CHECK-LABEL: @test24_recipX_noninf_cmp(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv ninf float 2.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[DIV]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float 2.0, %X
  %cmp = fcmp ogt float %div, 0.0
  ret i1 %cmp
}

; Do not fold 1.0 / X > 0.0 when ninf is missing
define i1 @test25_recipX_noninf_div(float %X) {
; CHECK-LABEL: @test25_recipX_noninf_div(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv float 2.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf ogt float [[DIV]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv float 2.0, %X
  %cmp = fcmp ninf ogt float %div, 0.0
  ret i1 %cmp
}

; Do not fold 1.0 / X > 0.0 with unordered predicates
define i1 @test26_recipX_unorderd(float %X) {
; CHECK-LABEL: @test26_recipX_unorderd(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv ninf float 2.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf ugt float [[DIV]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %div = fdiv ninf float 2.0, %X
  %cmp = fcmp ninf ugt float %div, 0.0
  ret i1 %cmp
}

; Fold <-1.0, -1.0> / X > <-0.0, -0.0>
define <2 x i1> @test27_recipX_gt_vecsplat(<2 x float> %X) {
; CHECK-LABEL: @test27_recipX_gt_vecsplat(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ninf olt <2 x float> [[X:%.*]], <float -0.000000e+00, float -0.000000e+00>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %div = fdiv ninf <2 x float> <float -1.0, float -1.0>, %X
  %cmp = fcmp ninf ogt <2 x float> %div, <float -0.0, float -0.0>
  ret <2 x i1> %cmp
}

