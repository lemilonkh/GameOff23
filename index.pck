GDPC                0                                                                         P   res://.godot/exported/133200997/export-3ad5c15c4f3250da0cc7c1af1770d85f-main.scn�      "      ��!㹚u|�f���%�/    P   res://.godot/exported/133200997/export-c2a7af834e91ff64325daddf58e45dc0-game.scn        �      8�ɥ=z!�^\reZ    ,   res://.godot/global_script_class_cache.cfg  @3             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�$      �      �Yz=������������    L   res://.godot/imported/pisilohe10.png-cfd0d533acfd4db0d486367c62dd527f.ctex  P      �      z&)�����V�'�	�    L   res://.godot/imported/pisilohe12.png-a96a2048b69ee4cd94816fd103b84635.ctex  �      ^      OK�o%�+j��֕�;e    P   res://.godot/imported/pisilohepunane3.png-06f6380473f244e8c53a34052d3f566b.ctex        �      F<쫁e��-%K�^|��       res://.godot/uid_cache.bin   7      �       t��VRY�3�;{�       res://icon.svg  `3      �      C��=U���^Qu��U3       res://icon.svg.import   �1      �       ���_�gǕd��7[��       res://project.binary 8      �      �Wq�#��E'</|%��       res://scenes/game.tscn.remap`2      a       Og��a�c��X07�I       res://scenes/main.tscn.remap�2      a       
��������S8z�s    (   res://scripts/pixel_perfect_scaling.gd  �      �      ��j ����,+�� �    $   res://sprites/pisilohe10.png.import        �       �C���/�v�J\�    $   res://sprites/pisilohe12.png.import 0      �       ���+O:�x0ӫ�ѭ    (   res://sprites/pisilohepunane3.png.import�#      �       �׭���	<pU^�Üt    /PI�RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script    
   Texture2D "   res://sprites/pisilohepunane3.png F�OYb&      local://PackedScene_ohelv          PackedScene          	         names "   	      game    texture_filter     metadata/_edit_vertical_guides_ "   metadata/_edit_horizontal_guides_    Node2D 	   Sprite2D 	   position    scale    texture    	   variants                        �C           pC
     �C  pC
      @   @                node_count             nodes        ��������       ����                                        ����                               conn_count              conns               node_paths              editable_instances              version             RSRC_��I��!���RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script '   res://scripts/pixel_perfect_scaling.gd ��������   PackedScene    res://scenes/game.tscn 7��e�Cd      local://PackedScene_jensh Q         PackedScene          	         names "         Main    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control 
   ColorRect    color    SubViewportContainer    stretch    SubViewport    handle_input_locally    size    render_target_update_mode    game    	   variants                        �?                                       �?             -                              node_count             nodes     I   ��������       ����                                                          	   	   ����                                       
                        ����                                ����            	      
              ���                    conn_count              conns               node_paths              editable_instances              version             RSRC�~�|Jb�8גb���extends Control

@onready var svc: SubViewportContainer = $SubViewportContainer

func _ready() -> void:
	get_viewport().size_changed.connect(on_screen_resized)
	svc.size = Vector2(ProjectSettings.get("display/window/size/viewport_width"), ProjectSettings.get("display/window/size/viewport_height"))
	on_screen_resized()

func on_screen_resized() -> void:
	var window_size := DisplayServer.window_get_size()
	var possible_scale := window_size / Vector2i(svc.size)
	var final_scale: Vector2i = max(1, min(possible_scale.x, possible_scale.y)) * Vector2i.ONE
	svc.scale = final_scale
	svc.position = Vector2(window_size) / 2 - svc.size * svc.scale / 2
�2ތ����GST2   d   d      ����               d d        l  RIFFd  WEBPVP8LW  /c�w�8�m%:��s�,u��̤���m%��#2�|�� �>�L#IV5�� ~���������- �����i��yձ���p��y�ߛ�_��i{W@M�}��3��]�g�@z%�$o���%g��+�� �K��I�"y��K��)�T�-�3��z߶��ms�^���'}-_d�B�>9�I���p�׷�~�R۷VJD�H�7�`9*�|ķ�㼌G���#��w�Z>�5������|M�x��75n�Sϗ������*T��ܸK�U(K���6��\�Y�2ŗK�����.W�ܮ��%"S����k�nn���{V�u�X��`������N��l`-畟}�K�,��f��b�]�گ�w\�da���R��A�C`"�x0�֒����f��{9q<4H�V����9��w���%>��˷{^�z�r�X���b5��W�E���`�y����/:�T!�Y���Gq8��̥�%_�-��g�M"�"���w<�\W[��C���(����K���N�-�*�"�r�;���_������_���(Q�:)��9����`Q&�]�^�g�/������2�����rm\հq��6M��D$�N��������i��H���	�>Mӝ��|	 ܕ��
����r��?�9�s_���j�����Cs�me 
�WU��*1�P*E����,�n��([a�X�Ns�Q��i�q�V����Np�O�?����o�E`G �r7u��a,S�������auOljC@ס�
t��B<L�8L�] �3���b �����w������q�K��# Q �������¢*
�4�V_���|ړ%3T�~C���i�QK�Bx?���0�C����T@t Q����	+9�=9b�R)5�i��a���~�J;(���LĢj��et]'��D��_k�P�S?L��dqɞ�k2m���'�Qnm㔊����k��������X0mXU]�Gj{UiR[�� �햶[�=�bf��p�6"�eOyѧ~L���b���Zۉ��'k������fÂ��
s1T�P�}��)�6Jē��3ֳ�D��=��9vPe���7}hu��<,�5��E�N�t:y��kQ�H �~(�ƾ�L}��xL�0ͫ�o�X�"��m剈y�%�ИR?�S�T�!���K���w��yy�Odm`�ATQ�!�i.���4,��۝!͊�w �.�c�OOOk7�6��T��ש�[�8�q�gmw(������7��|RAD�����Jo}_��???ͭ+���&��-{���o�bmӄ�c*Ke~]^ކ��Ҙ[�d��{�����~���wDT��@���fn���O%��ݶ�Z:��n�]��cD~�<�͛!��G<�c��:�����`��{f�:  E�s�B�s�\���*��a(ki,��)a[⎬Xa9u�%rTU�F�#	Z(�q,R�X�����#V���Y�s���u��D�9Hͷ�8�o�y��x,��SZ�鰌�C��d@�"B�$�>�Rz��*U�ܯ�����XĢD�_��DaG��@:��ƠOǺ6���+xip�s�h�W9��Qp�S��y)(�]{77{)�(��c��FlF�XHw��� �#�+1�h�V�yTh��Rwi�P�����Nj*Hv�+�޼��kn��V,�63��)	?~�9p�Zf]��ϋ�@%�$F~8��3W��k+0�*��ڻ"2=�s)c�܏k����\[�ZaLs�B9��s|Fs[?��.��\B�1��y��1p��G�}@�1�����	������s@�+k״uG��#sC����S���G � �����rN��k�9<�x\׮Z����%��<����/&� K{b\���N�x�/[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dxwjql3teox3p"
path="res://.godot/imported/pisilohe10.png-cfd0d533acfd4db0d486367c62dd527f.ctex"
metadata={
"vram_texture": false
}
 \Ƞ���bGST2   d   d      ����               d d        &  RIFF  WEBPVP8L  /c���(�l'�sT��?�
�p�$dl"�vr~��'�.�	,��X@-f`�H�����F��!��A@P��h �����4 [݀��L ʽ�7����|�"���6��{��I�Iֵ�:t�_x��'�$i�|�Ү�!�RAXU��ovF���>kE��$�q�@�����k�c|e'~~e���>���z�^/�b�1|Ln��|��ϻ}�<��j�G<��/�1���\^�2>�[�1duʳ̉���ʝ��?�����R^G��cȂ�Ϗ��Y%>Z�h�sw��`���W���E!��7�ॡ�,_}�C�(�y~k�Z�2py>�E��ի���[LG��U�
�^�J��oT�(;o��V���W�4�ܴ;O/7���)!&�\����C��� 4Ұ1=��Y�tĢ\�z<���}YW�[fn)Z��ly7��ʵy�0GU�2ֹ��ǭ~����0�fjq����p��D��>��f��j,m���W����o���4	Kl�i�>E�Z�o��	���d1�X����?����4��L"̂��9�~��{#�|�y�R�O��8����m�eå���ӜNzvW_8}�kO����IK��=��Xk�����qN�18�o�U+�2��\ZpJ��
;?��_���I�*ǖ%%���8/-~9�_���n~LU�sR�֜>>�΂��o�����,��H�ϲ�l��2�~tqߏ�Ϋ2��0R��ȇ��D��|<���/���m�U����%f)���Za^Zpu�����E�����TjK0H�>/����ֵ���-K.��kU ��PN�����/���l�'�'�*���d)���w�ն͇um�0y��EĔ���IIX�Ż�W�aۚ�,ۡm��ᆪ�Z�q��,��X�!���-lmX�V?�dY����l�bD@�̜��;��y��o��naq��7�P8'`��j_*�ܷ�x>���=l��7X�E� 9�V���2Qʹ�p�p��>�fk���kXW?H�H��*���n0�tU�&7�]}�¥2��K�-��}iÌ��^�E��6�?�ְ �p�*���J4����ة0��%��:�Ц�mn�U6�
S���V9�op�O��C���5}����R)A���@�VfM"�Ad��l~v��뾇��w��l�i�;XA��3�y�ٽ_�_�>^���$��� FՒ�Z��Df䌫�۰�0V�JC��TM9��9(G�13.���C�8���߇)�X�k%�Z��T�0��Y��Â��n�>�ޅ�4%)�;.Dd\�J�E��X�=8v,í���FQ͘�U[R$bqaQQ�r���~_:�� ��_ nB=��� �U�%�����0M�n@!*�PϨj�J;�IR�ZUU�q����ã ��:�D���
���&3SmD�2��Ǉ��@-�Ό�2s�1�/62S�>�YK�?���,��@����Z5Ӝ�j� ��T����-�s��u�{p�Ȫ�[f%!�U��|�p�Ӡ�� 1��f�j�Q�K%�3�a�]��M�<gD��R �UA)���ꩂkń��@$)�)H�hx��V��'�+I> b̬���R���g��T94���D��xLC<��P+�L�DU�j�{O�a:��+�i�5؍��3M��s��e����U���9�4@��"Toaz!Ǐ��ʤIHo�@T��#�H3sb1��PH�B'������S��u�n=\1MO��:�pv����=N�'�xo�=q����}5�^q��u����tv�f��/'�]�[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://ihyjqk56e7j7"
path="res://.godot/imported/pisilohe12.png-a96a2048b69ee4cd94816fd103b84635.ctex"
metadata={
"vram_texture": false
}
 d���䣜-�JGST2   d   d      ����               d d        �  RIFF�  WEBPVP8L�  /c�_�8�mS��"����m3�m+9_�$t�-�����4��F�PXZ��B�˰9������ ��?�iXΤ��V�;qt��]d*"���5߀����$��a]��s�/�]����4�`�U���ڜ-�W�B9{�t����h�vֶܶq҉(
k�܀!�0�x��o� ���.Z��IR��ؒs9~�ӿ�q]�߲�����������m%m��.є����+�]w=�����G�`S5ϻhq�U�33ۇ��o��[���W;{&���-��0���3[��6	�G���6G�Ң����}�n9sơ��JӀ��9��6�^������Uى,����e<HS����v�D,�Q���u�&!I��G!��^u�&�9%4��$$�H�B3���+77Q\堢�=��u��|�*���R�u�B��c�1H�I��u�>BjԷe)D43�$�u]o�x}=�q䔽��'�����n��KčfH)�-1�1J���5�*���>3�iN�)�>$�ڷF�7����1My�i�O�C�\&V��l$�S���f��Ğ��q4�lNO�LXi�Cѹ�#���
cy��Z�[�A�[�a�0á$�l����f�g����FJb����쉁ں$D}�5���<O�e�i����͈���cb���ǧ�����G3�z�O9��L^��]���j��6fS�H$̳&�$��6��,�ƍY�q���D��Y& ��!����ܗ#�3"�DD�)	������>�m�?eŘa����2�������)������!o\mq��يH���d�<{haoQƥ~P��ns_ݲhb����$@�� 3<�̲�ם��:�����,�RN^�&3Ų�a0j3U�X���(
3W?VH��{,�-��٫a�Բ��e��D"6EKB���%aY���U�_�jțeQj4�E���g��)�h͂�k׽�~�qP��ʃl,fh�
L�&��.S6\��N}��~̍��eQ-�D)�c�!��z��6�j��ʆl�{fT�h*�R��Ik�H�T��ի>S�UsG��R8o����E$A��@D¨>y��R�N�0V㪗s�R�Z kه|�b
a�gk��������^�*j��}L!Ʋ�p�.����'���.�����Mn�W~3g���VQ�1������1��hv3���ُΌ}��2��2�p�,y���A�"�������N�����J��V�Q�L#(�_��/������;�b��զ�0"��	)
�����y��l-�1�/�܂�W����r��f�X��B���?�\�ѝ/6����~��s�9,�}o��-ƨ�8���z�
s��m�ў.�����N�o(?�3��R]ʍ���)Ɛ�Er��m/h�\g�;X�wiVϗ��= 7*e�3�)FJ�m��G�������r�<�^�i^]� �E[�$%)sB��N��k�1%9��8�U���/���W�r�{�"��:}�W����c�T\��x����F�v��B�=3k=}\�^N��Ե1���ʮ�?����+h�TgS�!���Z� ����u�D1�ꐵvg[Y����/�B�Sw���CQ��e1����g#�J����.�w��O0����H�5G��b��ĺ
֘N����\�����8%4�&^�`j��C
!�zsLB�@��- L�f����^'aP�����ش�R��ۭ��VMEw�`R$�P1�X�AՀBD�7������D�$��!��iL�n�9<�/Iʜx,��<' p���Lҡ@����0p�3�.��gR!���ΫZ�ֲ�H���`C�v��Zi��m������_�4Wl};��u�v;��56��'q�U?�1V��[����yz����#O������r�	��[".��=[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bfn1ihtrrpb0i"
path="res://.godot/imported/pisilohepunane3.png-06f6380473f244e8c53a34052d3f566b.ctex"
metadata={
"vram_texture": false
}
 �(�kGST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[  O�\�KU[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dlgtiq6ub56wn"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 !��*�F�V�;�[remap]

path="res://.godot/exported/133200997/export-c2a7af834e91ff64325daddf58e45dc0-game.scn"
���P��>������[remap]

path="res://.godot/exported/133200997/export-3ad5c15c4f3250da0cc7c1af1770d85f-main.scn"
0�j����ɽgv��Llist=Array[Dictionary]([])
*f4�<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
��_���K�O   7��e�Cd   res://scenes/game.tscn'd	.}�X   res://scenes/main.tscn3x�g�ez   res://sprites/pisilohe10.png"U�@�v   res://sprites/pisilohe12.pngF�OYb&!   res://sprites/pisilohepunane3.png5!%�[�An   res://icon.svg�ECFG      application/config/name         GameOff 2023   application/run/main_scene          res://scenes/main.tscn     application/config/features(   "         4.1    GL Compatibility       application/config/icon         res://icon.svg  "   display/window/size/viewport_width      `  #   display/window/size/viewport_height      �     editor_plugins/enabled8   "      *   res://addons/coi_serviceworker/plugin.cfg   9   rendering/textures/canvas_textures/default_texture_filter          #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility<   rendering/textures/default_filters/use_nearest_mipmap_filter         �[�