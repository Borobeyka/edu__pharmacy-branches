PGDMP     6    ;                {            pharmacy_branches    14.5    14.5 L    K           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            L           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            M           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            N           1262    17985    pharmacy_branches    DATABASE     n   CREATE DATABASE pharmacy_branches WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Russia.1251';
 !   DROP DATABASE pharmacy_branches;
                postgres    false            �            1255    17986    create_order(integer, integer)    FUNCTION       CREATE FUNCTION public.create_order(branch_id integer, employee_id integer) RETURNS TABLE(new_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query INSERT INTO orders VALUES(DEFAULT, branch_id, employee_id, DEFAULT, DEFAULT) RETURNING id;
end;
$$;
 K   DROP FUNCTION public.create_order(branch_id integer, employee_id integer);
       public          postgres    false            O           0    0 =   FUNCTION create_order(branch_id integer, employee_id integer)    ACL     �   GRANT ALL ON FUNCTION public.create_order(branch_id integer, employee_id integer) TO manager;
GRANT ALL ON FUNCTION public.create_order(branch_id integer, employee_id integer) TO employee;
          public          postgres    false    241            �            1255    17987 0   create_orders_details(integer, integer, integer) 	   PROCEDURE     �   CREATE PROCEDURE public.create_orders_details(IN order_id integer, IN medicament_id integer, IN count integer)
    LANGUAGE plpgsql
    AS $$
begin
    INSERT INTO orders_details VALUES(DEFAULT, order_id, medicament_id, count);
end;
$$;
 n   DROP PROCEDURE public.create_orders_details(IN order_id integer, IN medicament_id integer, IN count integer);
       public          postgres    false            P           0    0 `   PROCEDURE create_orders_details(IN order_id integer, IN medicament_id integer, IN count integer)    ACL       GRANT ALL ON PROCEDURE public.create_orders_details(IN order_id integer, IN medicament_id integer, IN count integer) TO manager;
GRANT ALL ON PROCEDURE public.create_orders_details(IN order_id integer, IN medicament_id integer, IN count integer) TO employee;
          public          postgres    false    226            �            1255    17988 #   get_employees_by_branch_id(integer)    FUNCTION     �  CREATE FUNCTION public.get_employees_by_branch_id(branch_id integer) RETURNS TABLE(name character varying, surname character varying, position_title character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY EXECUTE format('SELECT e.name, e.surname, p.title FROM employees e LEFT JOIN positions p ON p.id = e.position_id
								WHERE e.branch_id = %L ORDER BY e.branch_id', branch_id);
END;
$$;
 D   DROP FUNCTION public.get_employees_by_branch_id(branch_id integer);
       public          postgres    false            Q           0    0 6   FUNCTION get_employees_by_branch_id(branch_id integer)    ACL     W   GRANT ALL ON FUNCTION public.get_employees_by_branch_id(branch_id integer) TO manager;
          public          postgres    false    227            �            1255    18098 F   get_filtered_medicaments(character varying, integer, integer, integer)    FUNCTION     4  CREATE FUNCTION public.get_filtered_medicaments(_title character varying, _category_id integer, _manufacturer_id integer, _position_id integer) RETURNS TABLE(id integer, title character varying, description character varying, category_id integer, manufacturer_id integer, image_url character varying, price real, is_prescription boolean, category_title character varying, manufacturer_title character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    statement TEXT;
BEGIN
	statement := 'SELECT med.*, c.title category_title, m.title manufacturer_title FROM medicaments med
		LEFT JOIN categories c ON c.id = med.category_id LEFT JOIN manufacturers m ON m.id = med.manufacturer_id WHERE 1=1 AND';
	IF (_title IS NOT NULL) THEN
		statement := format('%s med.title ILIKE ''%%%s%%'' OR med.description ILIKE ''%%%s%%'' AND', statement, _title, _title);
	END IF;
	IF (_category_id IS NOT NULL) THEN
		statement := format('%s med.category_id = %L AND', statement, _category_id);
	END IF;
	IF (_manufacturer_id IS NOT NULL) THEN
		statement := format('%s med.manufacturer_id = %L AND', statement, _manufacturer_id);
	END IF;
	IF (_position_id != 1) THEN
		statement := format('%s not med.is_prescription AND', statement);
	END IF;
	statement := format('%s 1=1 ORDER BY med.title;', statement);
	RETURN QUERY EXECUTE statement;
END;
$$;
 �   DROP FUNCTION public.get_filtered_medicaments(_title character varying, _category_id integer, _manufacturer_id integer, _position_id integer);
       public          postgres    false            �            1255    17990    get_manufacturer_by_id(integer)    FUNCTION     =  CREATE FUNCTION public.get_manufacturer_by_id(manufacturer_id integer) RETURNS TABLE(id integer, title character varying, address character varying, requisites character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY EXECUTE format('SELECT * FROM manufacturers WHERE id = %L', manufacturer_id);
END;
$$;
 F   DROP FUNCTION public.get_manufacturer_by_id(manufacturer_id integer);
       public          postgres    false            R           0    0 8   FUNCTION get_manufacturer_by_id(manufacturer_id integer)    ACL     �   GRANT ALL ON FUNCTION public.get_manufacturer_by_id(manufacturer_id integer) TO manager;
GRANT ALL ON FUNCTION public.get_manufacturer_by_id(manufacturer_id integer) TO employee;
          public          postgres    false    231            �            1255    18095    get_medicament_by_id(integer)    FUNCTION     |  CREATE FUNCTION public.get_medicament_by_id(medicament_id integer) RETURNS TABLE(id integer, title character varying, description character varying, category_id integer, manufacturer_id integer, image_url character varying, price real, is_prescription boolean, category_title character varying, manufacturer_title character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY EXECUTE format('SELECT m.*, c.title category_title, man.title manufacturer_title FROM medicaments m
    LEFT JOIN categories c ON c.id = m.category_id LEFT JOIN manufacturers man ON man.id = m.manufacturer_id WHERE m.id = %L', medicament_id);
END;
$$;
 B   DROP FUNCTION public.get_medicament_by_id(medicament_id integer);
       public          postgres    false            �            1255    17992    get_order_by_id(integer)    FUNCTION     <  CREATE FUNCTION public.get_order_by_id(order_id integer) RETURNS TABLE(id integer, branch_id integer, employee_id integer, amount real, date timestamp without time zone, employee_name character varying, employee_surname character varying, branch_address character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY EXECUTE format('SELECT o.*, e.name employee_name, e.surname employee_surname, b.address branch_address
    FROM orders o LEFT JOIN employees e ON e.id = o.employee_id LEFT JOIN branches b ON b.id = o.branch_id WHERE o.id = %L', order_id);
END;
$$;
 8   DROP FUNCTION public.get_order_by_id(order_id integer);
       public          postgres    false            S           0    0 *   FUNCTION get_order_by_id(order_id integer)    ACL     �   GRANT ALL ON FUNCTION public.get_order_by_id(order_id integer) TO manager;
GRANT ALL ON FUNCTION public.get_order_by_id(order_id integer) TO employee;
          public          postgres    false    242            �            1255    18096 !   get_orders_details_by_id(integer)    FUNCTION     G  CREATE FUNCTION public.get_orders_details_by_id(_order_id integer) RETURNS TABLE(id integer, order_id integer, medicament_id integer, count integer, title character varying, description character varying, category_id integer, manufacturer_id integer, image_url character varying, price real, is_prescription boolean, category_title character varying, manufacturer_title character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY EXECUTE format('SELECT od.*, m.title, m.description, m.category_id, m.manufacturer_id, m.image_url, m.price,
    c.title category_title, man.title manufacturer_title FROM orders_details od LEFT JOIN medicaments m ON m.id = od.medicament_id
    LEFT JOIN categories c ON c.id = m.category_id LEFT JOIN manufacturers man ON man.id = m.manufacturer_id
    WHERE od.order_id = %L', _order_id);
END;
$$;
 B   DROP FUNCTION public.get_orders_details_by_id(_order_id integer);
       public          postgres    false            �            1255    18097 h   medicament_add(character varying, character varying, integer, integer, character varying, real, boolean)    FUNCTION     �  CREATE FUNCTION public.medicament_add(title character varying, description character varying, category_id integer, manufacturer_id integer, image_url character varying, price real, is_prescription boolean) RETURNS TABLE(new_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query INSERT INTO medicaments VALUES(DEFAULT, title, description, category_id, manufacturer_id, image_url, price) RETURNING id;
end;
$$;
 �   DROP FUNCTION public.medicament_add(title character varying, description character varying, category_id integer, manufacturer_id integer, image_url character varying, price real, is_prescription boolean);
       public          postgres    false            �            1255    17995    trigger_orders_details()    FUNCTION       CREATE FUNCTION public.trigger_orders_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE orders SET amount = amount + (SELECT price FROM medicaments WHERE id = new.medicament_id) * new.count WHERE id = new.order_id;
    RETURN new;
END;
$$;
 /   DROP FUNCTION public.trigger_orders_details();
       public          postgres    false            �            1259    17996    branches    TABLE     �   CREATE TABLE public.branches (
    id integer NOT NULL,
    address character varying(128) NOT NULL,
    time_open time without time zone NOT NULL,
    time_close time without time zone NOT NULL
);
    DROP TABLE public.branches;
       public         heap    postgres    false            T           0    0    TABLE branches    ACL     s   GRANT SELECT,INSERT,UPDATE ON TABLE public.branches TO manager;
GRANT SELECT ON TABLE public.branches TO employee;
          public          postgres    false    209            �            1259    17999    branches_id_seq    SEQUENCE     �   ALTER TABLE public.branches ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    209            �            1259    18000 
   categories    TABLE     f   CREATE TABLE public.categories (
    id integer NOT NULL,
    title character varying(64) NOT NULL
);
    DROP TABLE public.categories;
       public         heap    postgres    false            U           0    0    TABLE categories    ACL     w   GRANT SELECT,INSERT,UPDATE ON TABLE public.categories TO manager;
GRANT SELECT ON TABLE public.categories TO employee;
          public          postgres    false    211            �            1259    18003    categories_id_seq    SEQUENCE     �   ALTER TABLE public.categories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    211            �            1259    18004 	   employees    TABLE     ?  CREATE TABLE public.employees (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    surname character varying(32) DEFAULT ''::character varying,
    password character varying(256) NOT NULL,
    position_id integer NOT NULL,
    branch_id integer NOT NULL,
    login character varying(32) NOT NULL
);
    DROP TABLE public.employees;
       public         heap    postgres    false            V           0    0    TABLE employees    ACL     u   GRANT SELECT,INSERT,DELETE ON TABLE public.employees TO manager;
GRANT SELECT ON TABLE public.employees TO employee;
          public          postgres    false    213            �            1259    18008    employees_id_seq    SEQUENCE     �   ALTER TABLE public.employees ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    213            �            1259    18009    orders    TABLE     �   CREATE TABLE public.orders (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    employee_id integer NOT NULL,
    amount real DEFAULT 0,
    date timestamp without time zone DEFAULT now()
);
    DROP TABLE public.orders;
       public         heap    postgres    false            W           0    0    TABLE orders    ACL     a   GRANT SELECT ON TABLE public.orders TO manager;
GRANT SELECT ON TABLE public.orders TO employee;
          public          postgres    false    215            �            1259    18014    get_all_orders    VIEW     y  CREATE VIEW public.get_all_orders AS
 SELECT o.id,
    o.branch_id,
    o.employee_id,
    o.amount,
    o.date,
    b.address AS branch_address,
    e.name AS employee_name,
    e.surname AS employee_surname
   FROM ((public.orders o
     LEFT JOIN public.branches b ON ((b.id = o.branch_id)))
     LEFT JOIN public.employees e ON ((e.id = o.employee_id)))
  ORDER BY o.date;
 !   DROP VIEW public.get_all_orders;
       public          postgres    false    215    215    215    215    215    213    213    213    209    209            �            1259    18018    manufacturers    TABLE       CREATE TABLE public.manufacturers (
    id integer NOT NULL,
    title character varying(64) NOT NULL,
    address character varying(128) DEFAULT 'Адрес не указан'::character varying,
    requisutes character varying(256) DEFAULT ''::character varying
);
 !   DROP TABLE public.manufacturers;
       public         heap    postgres    false            X           0    0    TABLE manufacturers    ACL     o   GRANT SELECT ON TABLE public.manufacturers TO manager;
GRANT SELECT ON TABLE public.manufacturers TO employee;
          public          postgres    false    217            �            1259    18023    manufacturers_id_seq    SEQUENCE     �   ALTER TABLE public.manufacturers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    217            �            1259    18024    medicaments    TABLE     K  CREATE TABLE public.medicaments (
    id integer NOT NULL,
    title character varying(64) NOT NULL,
    description character varying(512),
    category_id integer NOT NULL,
    manufacturer_id integer NOT NULL,
    image_url character varying(512),
    price real DEFAULT 0 NOT NULL,
    is_prescription boolean DEFAULT false
);
    DROP TABLE public.medicaments;
       public         heap    postgres    false            Y           0    0    TABLE medicaments    ACL     y   GRANT SELECT,INSERT,UPDATE ON TABLE public.medicaments TO manager;
GRANT SELECT ON TABLE public.medicaments TO employee;
          public          postgres    false    219            �            1259    18030    medicaments_id_seq    SEQUENCE     �   ALTER TABLE public.medicaments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.medicaments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    219            �            1259    18031    orders_details    TABLE     �   CREATE TABLE public.orders_details (
    id integer NOT NULL,
    order_id integer NOT NULL,
    medicament_id integer NOT NULL,
    count integer DEFAULT 1
);
 "   DROP TABLE public.orders_details;
       public         heap    postgres    false            Z           0    0    TABLE orders_details    ACL     x   GRANT SELECT,INSERT ON TABLE public.orders_details TO manager;
GRANT SELECT ON TABLE public.orders_details TO employee;
          public          postgres    false    221            �            1259    18035    orders-details_id_seq    SEQUENCE     �   ALTER TABLE public.orders_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."orders-details_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    221            �            1259    18036    orders_id_seq    SEQUENCE     �   ALTER TABLE public.orders ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    215            �            1259    18037 	   positions    TABLE     e   CREATE TABLE public.positions (
    id integer NOT NULL,
    title character varying(64) NOT NULL
);
    DROP TABLE public.positions;
       public         heap    postgres    false            [           0    0    TABLE positions    ACL     u   GRANT SELECT,INSERT,DELETE ON TABLE public.positions TO manager;
GRANT SELECT ON TABLE public.positions TO employee;
          public          postgres    false    224            �            1259    18040    positions_id_seq    SEQUENCE     �   ALTER TABLE public.positions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    224            9          0    17996    branches 
   TABLE DATA           F   COPY public.branches (id, address, time_open, time_close) FROM stdin;
    public          postgres    false    209   mn       ;          0    18000 
   categories 
   TABLE DATA           /   COPY public.categories (id, title) FROM stdin;
    public          postgres    false    211   �n       =          0    18004 	   employees 
   TABLE DATA           _   COPY public.employees (id, name, surname, password, position_id, branch_id, login) FROM stdin;
    public          postgres    false    213   bo       @          0    18018    manufacturers 
   TABLE DATA           G   COPY public.manufacturers (id, title, address, requisutes) FROM stdin;
    public          postgres    false    217   �p       B          0    18024    medicaments 
   TABLE DATA           ~   COPY public.medicaments (id, title, description, category_id, manufacturer_id, image_url, price, is_prescription) FROM stdin;
    public          postgres    false    219   �q       ?          0    18009    orders 
   TABLE DATA           J   COPY public.orders (id, branch_id, employee_id, amount, date) FROM stdin;
    public          postgres    false    215   fv       D          0    18031    orders_details 
   TABLE DATA           L   COPY public.orders_details (id, order_id, medicament_id, count) FROM stdin;
    public          postgres    false    221   �v       G          0    18037 	   positions 
   TABLE DATA           .   COPY public.positions (id, title) FROM stdin;
    public          postgres    false    224   'w       \           0    0    branches_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.branches_id_seq', 5, true);
          public          postgres    false    210            ]           0    0    categories_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.categories_id_seq', 3, true);
          public          postgres    false    212            ^           0    0    employees_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.employees_id_seq', 3, true);
          public          postgres    false    214            _           0    0    manufacturers_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.manufacturers_id_seq', 2, true);
          public          postgres    false    218            `           0    0    medicaments_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.medicaments_id_seq', 6, true);
          public          postgres    false    220            a           0    0    orders-details_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public."orders-details_id_seq"', 6, true);
          public          postgres    false    222            b           0    0    orders_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.orders_id_seq', 9, true);
          public          postgres    false    223            c           0    0    positions_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.positions_id_seq', 3, true);
          public          postgres    false    225            �           2606    18042    branches branches_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.branches DROP CONSTRAINT branches_pkey;
       public            postgres    false    209            �           2606    18044    categories categories_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_pkey;
       public            postgres    false    211            �           2606    18046    employees employees_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.employees DROP CONSTRAINT employees_pkey;
       public            postgres    false    213            �           2606    18048     manufacturers manufacturers_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.manufacturers DROP CONSTRAINT manufacturers_pkey;
       public            postgres    false    217            �           2606    18050    medicaments medicaments_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.medicaments
    ADD CONSTRAINT medicaments_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.medicaments DROP CONSTRAINT medicaments_pkey;
       public            postgres    false    219            �           2606    18052 "   orders_details orders-details_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.orders_details
    ADD CONSTRAINT "orders-details_pkey" PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.orders_details DROP CONSTRAINT "orders-details_pkey";
       public            postgres    false    221            �           2606    18054    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    215            �           2606    18056    positions positions_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.positions DROP CONSTRAINT positions_pkey;
       public            postgres    false    224            �           2620    18057 %   orders_details trigger_orders_details    TRIGGER     �   CREATE TRIGGER trigger_orders_details AFTER INSERT ON public.orders_details FOR EACH ROW EXECUTE FUNCTION public.trigger_orders_details();
 >   DROP TRIGGER trigger_orders_details ON public.orders_details;
       public          postgres    false    240    221            �           2606    18058     employees FK_branch_id__branches    FK CONSTRAINT     �   ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_branch_id__branches" FOREIGN KEY (branch_id) REFERENCES public.branches(id) NOT VALID;
 L   ALTER TABLE ONLY public.employees DROP CONSTRAINT "FK_branch_id__branches";
       public          postgres    false    213    209    3222            �           2606    18063    orders FK_branch_id__branches    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "FK_branch_id__branches" FOREIGN KEY (branch_id) REFERENCES public.branches(id) NOT VALID;
 I   ALTER TABLE ONLY public.orders DROP CONSTRAINT "FK_branch_id__branches";
       public          postgres    false    215    209    3222            �           2606    18068 &   medicaments FK_category_id__categories    FK CONSTRAINT     �   ALTER TABLE ONLY public.medicaments
    ADD CONSTRAINT "FK_category_id__categories" FOREIGN KEY (category_id) REFERENCES public.categories(id) NOT VALID;
 R   ALTER TABLE ONLY public.medicaments DROP CONSTRAINT "FK_category_id__categories";
       public          postgres    false    219    3224    211            �           2606    18073     orders FK_employee_id__employees    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "FK_employee_id__employees" FOREIGN KEY (employee_id) REFERENCES public.employees(id) NOT VALID;
 L   ALTER TABLE ONLY public.orders DROP CONSTRAINT "FK_employee_id__employees";
       public          postgres    false    3226    215    213            �           2606    18078 -   medicaments FK_manufacturer_id__manufacturers    FK CONSTRAINT     �   ALTER TABLE ONLY public.medicaments
    ADD CONSTRAINT "FK_manufacturer_id__manufacturers" FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturers(id) NOT VALID;
 Y   ALTER TABLE ONLY public.medicaments DROP CONSTRAINT "FK_manufacturer_id__manufacturers";
       public          postgres    false    217    3230    219            �           2606    18083 "   orders_details FK_order_id__orders    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders_details
    ADD CONSTRAINT "FK_order_id__orders" FOREIGN KEY (order_id) REFERENCES public.orders(id) NOT VALID;
 N   ALTER TABLE ONLY public.orders_details DROP CONSTRAINT "FK_order_id__orders";
       public          postgres    false    221    3228    215            �           2606    18088 #   employees FK_position_id__positions    FK CONSTRAINT     �   ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "FK_position_id__positions" FOREIGN KEY (position_id) REFERENCES public.positions(id) NOT VALID;
 O   ALTER TABLE ONLY public.employees DROP CONSTRAINT "FK_position_id__positions";
       public          postgres    false    224    213    3236            9   x   x�3��|a���.츰�¾�.l�د�pa���������qA\&0-�/l *�w��b�Ŏ����^� �h������qޅ�`M���l�j1�Q���MZa�=... #jE�      ;   ]   x�-��	�0D���j;�r��[p�CP�f:�G<��Vֈl�q �1�R��T
���eg�9N��R:�ƥ�	����}�]e"���B	      =   R  x�uнNA���9�&�q��C(FI$Q6{��)"`ka��"	��3콑Ki���d�_�24	��*��ﰭ��3n��]\wa]=�M��>h�.Ⱦ����������y��Q$�[D��K�2��8�՞����0�r�M�"��X	Mx2)o�ټ��<	oaS-�nS-~{��&EL��mָ����0�pt͵�h)�(�eZQ�e�zS(��5j� @�(��IA2u���,	�բZU�{�K��W؆��5��օ�=t��ߴ����:1D�� '�;��B_�i�u�����za�ɂ`¢Ǻѵ-g5�^��4��T�+      @   �   x�u��n�@Dk�Wlc�َ)���t�|N
JOA"�&��v�H���?�U�B��vfVkl�8�7[��Р�3��"�-[T(�B�gԢ�c^nQ���UH(#�C2}�?�J^`�Ja����o"bΤEL^w<Gë�|,j�/bn�v@7��GÁ&���`4yz�]=,���/��QR��F��F��#5'i��O�?P�� F�#��/@g��      B   �  x��V�N#G]7_Q)R"ᶱ1�Yf)�(�5��p0��+����8�&�H���"~��~t[�/����{�ڃH�YMW�����YG��;�Bw�T�u�CG��{zj��7-si�J�q�n��Hthn��:���S�B�q��UO�"=<aC��}s8����������D0(F��5���}��_��?��q�S��C����ǈ����gpu�$�=����:R0�C�#���2/q2P�Z>� lx�$$�Ӂ���""�[�;���3I"$����H@�̍�|i^!�� ���`PS�*)�E��1EĬ��D��ڱz��w��wj���3%EPq�x��cB������LY�u-g��\�4��� ���z���7��>�:��t�+����b�k`[D�� �}$4��ւ?���� ����@�QM�v�,�v�������so�;O���^�Qq���m��$�]�W�ӇG��㴗����7_:�b��^�9�'��%�Ih�<q��>Q�Ħ2S��<��쇹U����XQ�F�gK�1��B0��|�-��V��7�_8�#���@�Eo��@O�4DiY�a�2b_Km|��^{�6�'V��|�䃙�*`?�ڐAK3F� ��u�B�I(���$��Gl�9����MH1���W�-b � 9!�c��C>N�e�Of����N�A
C!&�nH	!N,�YڒY-�M�V�Y�N�R�2�������=��E��6����m+�g?cDC�[%��X�Z׮���dvJ'��y�����ۨ6�'��������t~#���U��n�E~�P?�[?�6�L���h���R��~{��l�Hm8dL��-4u��vrS<������ߞy�����L.�6�-9n��6��#�G#r�-������-II�7Ŵ�L������S�+U�w� ����֏~G���ʿ��'�qG-Hѷ��l��#�7��_O���������/o��A��A�`+�(����P�O��B�C�]�|.k�B=�d��G_,r�'�����s�]��b��|�[S�:^�d��ˈ�+�Nb����o�ڑC~<[�*��c�����Og1��]8�5qe�Ln�b|>L���{�O�F�&�myR˹5�U+��\�P��K��z��Y�z^5WȔ�2��g#_t�+[�����m�:      ?   n   x�]ͱ�@��Pb�w@-��J4R�f���H	
?5O݇�(�S:#�x]Đ�V}���d����@��@k��l+.�,s�UN���mp_Ct?�]�&��j�3X�!S      D   3   x�ȱ  ���N���ADu�
���0�+�����N+�A��b      G   n   x�%���0C��Sd��:S�
�e 
��Ү�8�O�l7�;�Z2�Y���PyEu�ٕ�W�do.�gF��7�*o�NJ�+%V���>/.gd��e;���x�Q$     