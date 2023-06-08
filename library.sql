PGDMP     3    $                {            library    15.2    15.2 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    122894    library    DATABASE     {   CREATE DATABASE library WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE library;
                postgres    false                        2615    122895    library    SCHEMA        CREATE SCHEMA library;
    DROP SCHEMA library;
                postgres    false            �            1255    123450 ,   check_book_availability(text, integer, text)    FUNCTION     :  CREATE FUNCTION library.check_book_availability(_title text, _volume integer, _author text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(c.copy_id)
        FROM book b
            JOIN card_index ci on b.book_id = ci.book_id
            JOIN incoming i on ci.incoming_id = i.incoming_id
            JOIN copy c on i.copy_id = c.copy_id
        WHERE b.title = _title
            AND b.volume_number = _volume
            AND b.author = _author
            AND c.status = 'возвращенный'
    );
END;
$$;
 [   DROP FUNCTION library.check_book_availability(_title text, _volume integer, _author text);
       library          postgres    false    6            �            1255    123451 0   insert_new_book(text, integer, text, text, text) 	   PROCEDURE     ?  CREATE PROCEDURE library.insert_new_book(IN _title text, IN _volume integer, IN _author text, IN _field text, IN _language text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO book(title, volume_number, author, field_of_knowledge, language)
    VALUES (_title, _volume, _field, _author, _language);
END;
$$;
 �   DROP PROCEDURE library.insert_new_book(IN _title text, IN _volume integer, IN _author text, IN _field text, IN _language text);
       library          postgres    false    6            �            1255    123452 3   insert_new_reader(bigint, text, text, text, bigint) 	   PROCEDURE     f  CREATE PROCEDURE library.insert_new_reader(IN _passport bigint, IN _name text, IN _email text, IN _address text, IN _phone bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    reader_exists INT;
BEGIN
    SELECT COUNT(reader_id) INTO reader_exists
    FROM reader
    WHERE _passport = passport_details;

    IF reader_exists = 0 THEN
        INSERT INTO reader(passport_details, reader_full_name, email, address, phone_number)
        VALUES (_passport, _name, _email, _address, _phone);
    ELSE
        RAISE NOTICE 'Читатель уже есть в базе данных';
    END IF;
END;
$$;
 �   DROP PROCEDURE library.insert_new_reader(IN _passport bigint, IN _name text, IN _email text, IN _address text, IN _phone bigint);
       library          postgres    false    6                       1255    123471    log_subcription()    FUNCTION       CREATE FUNCTION library.log_subcription() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO subcription_audit(operation, subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty)
        SELECT TG_OP,
            OLD.subscription_id,
            OLD.employee_id,
            OLD.copy_id,
            OLD.date_subscribed,
            OLD.date_return,
            OLD.date_real_return,
            OLD.status,
            OLD.penalty;
        RETURN OLD;
    ELSE
        INSERT INTO subcription_audit(operation, subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty)
        SELECT TG_OP,
            NEW.subscription_id,
            NEW.employee_id,
            NEW.copy_id,
            NEW.date_subscribed,
            NEW.date_return,
            NEW.date_real_return,
            NEW.status,
            NEW.penalty;
        RETURN NEW;
    END IF;
END;
$$;
 )   DROP FUNCTION library.log_subcription();
       library          postgres    false    6                       1255    123462    log_subcription()    FUNCTION       CREATE FUNCTION public.log_subcription() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO subcription_audit(operation, subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty)
        SELECT TG_OP,
            OLD.subscription_id,
            OLD.employee_id,
            OLD.copy_id,
            OLD.date_subscribed,
            OLD.date_return,
            OLD.date_real_return,
            OLD.status,
            OLD.penalty;
        RETURN OLD;
    ELSE
        INSERT INTO subcription_audit(operation, subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty)
        SELECT TG_OP,
            NEW.subscription_id,
            NEW.employee_id,
            NEW.copy_id,
            NEW.date_subscribed,
            NEW.date_return,
            NEW.date_real_return,
            NEW.status,
            NEW.penalty;
        RETURN NEW;
    END IF;
END;
$$;
 (   DROP FUNCTION public.log_subcription();
       public          postgres    false            �            1259    123114 	   affiliate    TABLE     �   CREATE TABLE library.affiliate (
    affiliate_id integer NOT NULL,
    affiliate_name character varying(35) NOT NULL,
    address character varying(35) NOT NULL,
    level character varying(20) NOT NULL
);
    DROP TABLE library.affiliate;
       library         heap    postgres    false    6            �            1259    123113    affiliate_affiliate_id_seq    SEQUENCE     �   CREATE SEQUENCE library.affiliate_affiliate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE library.affiliate_affiliate_id_seq;
       library          postgres    false    6    240            �           0    0    affiliate_affiliate_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE library.affiliate_affiliate_id_seq OWNED BY library.affiliate.affiliate_id;
          library          postgres    false    239            �            1259    122946    book    TABLE       CREATE TABLE library.book (
    book_id integer NOT NULL,
    title character varying(65) NOT NULL,
    volume_number integer NOT NULL,
    author character varying(35) NOT NULL,
    field_of_knowledge character varying(35) NOT NULL,
    language character varying(20)
);
    DROP TABLE library.book;
       library         heap    postgres    false    6            �            1259    122945    book_book_id_seq    SEQUENCE     �   CREATE SEQUENCE library.book_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE library.book_book_id_seq;
       library          postgres    false    6    216            �           0    0    book_book_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE library.book_book_id_seq OWNED BY library.book.book_id;
          library          postgres    false    215            �            1259    122968 
   card_index    TABLE     ^  CREATE TABLE library.card_index (
    card_index_id integer NOT NULL,
    book_id integer NOT NULL,
    publisher_id integer NOT NULL,
    publisher_type character varying(20) NOT NULL,
    translator character varying(35) NOT NULL,
    publish_year integer NOT NULL,
    copies_count integer NOT NULL,
    compiler character varying(35) NOT NULL
);
    DROP TABLE library.card_index;
       library         heap    postgres    false    6            �            1259    122975    copy    TABLE     �   CREATE TABLE library.copy (
    copy_id integer NOT NULL,
    status character varying(20) NOT NULL,
    retention_period date NOT NULL,
    incoming_id integer NOT NULL
);
    DROP TABLE library.copy;
       library         heap    postgres    false    6            �            1259    122974    copy_copy_id_seq    SEQUENCE     �   CREATE SEQUENCE library.copy_copy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE library.copy_copy_id_seq;
       library          postgres    false    6    224            �           0    0    copy_copy_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE library.copy_copy_id_seq OWNED BY library.copy.copy_id;
          library          postgres    false    223            �            1259    122982    copy_storage    TABLE     �   CREATE TABLE library.copy_storage (
    copy_storage_id integer NOT NULL,
    copy_id integer NOT NULL,
    storage_id integer NOT NULL,
    status character varying(20) NOT NULL,
    date_start date NOT NULL,
    date_end date NOT NULL
);
 !   DROP TABLE library.copy_storage;
       library         heap    postgres    false    6            �            1259    122981     copy_storage_copy_storage_id_seq    SEQUENCE     �   CREATE SEQUENCE library.copy_storage_copy_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE library.copy_storage_copy_storage_id_seq;
       library          postgres    false    226    6            �           0    0     copy_storage_copy_storage_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE library.copy_storage_copy_storage_id_seq OWNED BY library.copy_storage.copy_storage_id;
          library          postgres    false    225            �            1259    123253    debtors    VIEW     �   CREATE VIEW library.debtors AS
SELECT
    NULL::integer AS reader_id,
    NULL::character varying(45) AS reader_full_name,
    NULL::character varying(45) AS address,
    NULL::bigint AS phone_number,
    NULL::bigint AS overdue_subscriptions;
    DROP VIEW library.debtors;
       library          postgres    false    6            �            1259    123751    document    TABLE     �   CREATE TABLE library.document (
    document_id integer NOT NULL,
    employee_id integer NOT NULL,
    copy_id integer NOT NULL,
    document_type character varying(35) NOT NULL
);
    DROP TABLE library.document;
       library         heap    postgres    false    6            �            1259    123750    document_document_id_seq    SEQUENCE     �   CREATE SEQUENCE library.document_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE library.document_document_id_seq;
       library          postgres    false    6    247            �           0    0    document_document_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE library.document_document_id_seq OWNED BY library.document.document_id;
          library          postgres    false    246            �            1259    123024    employee    TABLE       CREATE TABLE library.employee (
    employee_id integer NOT NULL,
    employee_full_name character varying(35) NOT NULL,
    affiliate_id integer NOT NULL,
    "position" character varying(20) NOT NULL,
    email character varying(45) NOT NULL,
    phone_number bigint NOT NULL
);
    DROP TABLE library.employee;
       library         heap    postgres    false    6            �            1259    123023    employee_employee_id_seq    SEQUENCE     �   CREATE SEQUENCE library.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE library.employee_employee_id_seq;
       library          postgres    false    6    238            �           0    0    employee_employee_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE library.employee_employee_id_seq OWNED BY library.employee.employee_id;
          library          postgres    false    237            �            1259    122960    incoming    TABLE     �   CREATE TABLE library.incoming (
    incoming_id integer NOT NULL,
    supplier_invoice_id integer NOT NULL,
    date date NOT NULL,
    card_index_id integer NOT NULL
);
    DROP TABLE library.incoming;
       library         heap    postgres    false    6            �            1259    122959    incoming_incoming_id_seq    SEQUENCE     �   CREATE SEQUENCE library.incoming_incoming_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE library.incoming_incoming_id_seq;
       library          postgres    false    6    220            �           0    0    incoming_incoming_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE library.incoming_incoming_id_seq OWNED BY library.incoming.incoming_id;
          library          postgres    false    219            �            1259    122996 	   publisher    TABLE     �   CREATE TABLE library.publisher (
    publisher_id integer NOT NULL,
    publisher_name character varying(35) NOT NULL,
    city character varying(20) NOT NULL
);
    DROP TABLE library.publisher;
       library         heap    postgres    false    6            �            1259    122995    publisher_publisher_id_seq    SEQUENCE     �   CREATE SEQUENCE library.publisher_publisher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE library.publisher_publisher_id_seq;
       library          postgres    false    6    230            �           0    0    publisher_publisher_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE library.publisher_publisher_id_seq OWNED BY library.publisher.publisher_id;
          library          postgres    false    229            �            1259    123003    reader    TABLE       CREATE TABLE library.reader (
    reader_id integer NOT NULL,
    passport_details bigint NOT NULL,
    reader_full_name character varying(45) NOT NULL,
    email character varying(40) NOT NULL,
    address character varying(45) NOT NULL,
    phone_number bigint NOT NULL
);
    DROP TABLE library.reader;
       library         heap    postgres    false    6            �            1259    123002    reader_reader_id_seq    SEQUENCE     �   CREATE SEQUENCE library.reader_reader_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE library.reader_reader_id_seq;
       library          postgres    false    232    6            �           0    0    reader_reader_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE library.reader_reader_id_seq OWNED BY library.reader.reader_id;
          library          postgres    false    231            �            1259    123010    registered_reader    TABLE     �   CREATE TABLE library.registered_reader (
    registered_reader_id integer NOT NULL,
    reader_id integer NOT NULL,
    subscription_id integer NOT NULL,
    date_start date NOT NULL,
    date_end date NOT NULL
);
 &   DROP TABLE library.registered_reader;
       library         heap    postgres    false    6            �            1259    123009 *   registered_reader_registered_reader_id_seq    SEQUENCE     �   CREATE SEQUENCE library.registered_reader_registered_reader_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE library.registered_reader_registered_reader_id_seq;
       library          postgres    false    6    234            �           0    0 *   registered_reader_registered_reader_id_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE library.registered_reader_registered_reader_id_seq OWNED BY library.registered_reader.registered_reader_id;
          library          postgres    false    233            �            1259    123721    registering    TABLE     �   CREATE TABLE library.registering (
    registering_id integer NOT NULL,
    incoming_id integer NOT NULL,
    employee_id integer NOT NULL,
    date date NOT NULL,
    CONSTRAINT ch_date CHECK ((date < now()))
);
     DROP TABLE library.registering;
       library         heap    postgres    false    6            �            1259    123720    registering_registering_id_seq    SEQUENCE     �   CREATE SEQUENCE library.registering_registering_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE library.registering_registering_id_seq;
       library          postgres    false    245    6            �           0    0    registering_registering_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE library.registering_registering_id_seq OWNED BY library.registering.registering_id;
          library          postgres    false    244            �            1259    122989    storage    TABLE     �   CREATE TABLE library.storage (
    storage_id integer NOT NULL,
    shelf_number integer NOT NULL,
    rack_number integer NOT NULL,
    room_number integer NOT NULL
);
    DROP TABLE library.storage;
       library         heap    postgres    false    6            �            1259    122988    storage_storage_id_seq    SEQUENCE     �   CREATE SEQUENCE library.storage_storage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE library.storage_storage_id_seq;
       library          postgres    false    6    228            �           0    0    storage_storage_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE library.storage_storage_id_seq OWNED BY library.storage.storage_id;
          library          postgres    false    227            �            1259    123464    subcription_audit    TABLE     �  CREATE TABLE library.subcription_audit (
    id integer NOT NULL,
    operation character varying(6) NOT NULL,
    operation_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    subscription_id integer NOT NULL,
    employee_id integer NOT NULL,
    copy_id integer NOT NULL,
    date_subscribed date NOT NULL,
    date_return date NOT NULL,
    date_real_return date,
    status character varying(20) NOT NULL,
    penalty character varying(20)
);
 &   DROP TABLE library.subcription_audit;
       library         heap    postgres    false    6            �            1259    123463    subcription_audit_id_seq    SEQUENCE     �   CREATE SEQUENCE library.subcription_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE library.subcription_audit_id_seq;
       library          postgres    false    6    243            �           0    0    subcription_audit_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE library.subcription_audit_id_seq OWNED BY library.subcription_audit.id;
          library          postgres    false    242            �            1259    123017    subscription    TABLE     7  CREATE TABLE library.subscription (
    subscription_id integer NOT NULL,
    employee_id integer NOT NULL,
    copy_id integer NOT NULL,
    date_subscribed date NOT NULL,
    date_return date NOT NULL,
    date_real_return date,
    status character varying(20) NOT NULL,
    penalty character varying(20)
);
 !   DROP TABLE library.subscription;
       library         heap    postgres    false    6            �            1259    123016     subscription_subscription_id_seq    SEQUENCE     �   CREATE SEQUENCE library.subscription_subscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE library.subscription_subscription_id_seq;
       library          postgres    false    6    236            �           0    0     subscription_subscription_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE library.subscription_subscription_id_seq OWNED BY library.subscription.subscription_id;
          library          postgres    false    235            �            1259    122953    supplier_invoice    TABLE     �   CREATE TABLE library.supplier_invoice (
    supplier_invoice_id integer NOT NULL,
    supplier_name character varying(35) NOT NULL,
    date date NOT NULL
);
 %   DROP TABLE library.supplier_invoice;
       library         heap    postgres    false    6            �            1259    122952 (   supplier_invoice_supplier_invoice_id_seq    SEQUENCE     �   CREATE SEQUENCE library.supplier_invoice_supplier_invoice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 @   DROP SEQUENCE library.supplier_invoice_supplier_invoice_id_seq;
       library          postgres    false    218    6            �           0    0 (   supplier_invoice_supplier_invoice_id_seq    SEQUENCE OWNED BY     w   ALTER SEQUENCE library.supplier_invoice_supplier_invoice_id_seq OWNED BY library.supplier_invoice.supplier_invoice_id;
          library          postgres    false    217            �            1259    122967    сard_Index_сard_Index_id_seq    SEQUENCE     �   CREATE SEQUENCE library."сard_Index_сard_Index_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE library."сard_Index_сard_Index_id_seq";
       library          postgres    false    222    6            �           0    0    сard_Index_сard_Index_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE library."сard_Index_сard_Index_id_seq" OWNED BY library.card_index.card_index_id;
          library          postgres    false    221            �           2604    123117    affiliate affiliate_id    DEFAULT     �   ALTER TABLE ONLY library.affiliate ALTER COLUMN affiliate_id SET DEFAULT nextval('library.affiliate_affiliate_id_seq'::regclass);
 F   ALTER TABLE library.affiliate ALTER COLUMN affiliate_id DROP DEFAULT;
       library          postgres    false    240    239    240            �           2604    122949    book book_id    DEFAULT     n   ALTER TABLE ONLY library.book ALTER COLUMN book_id SET DEFAULT nextval('library.book_book_id_seq'::regclass);
 <   ALTER TABLE library.book ALTER COLUMN book_id DROP DEFAULT;
       library          postgres    false    215    216    216            �           2604    122971    card_index card_index_id    DEFAULT     �   ALTER TABLE ONLY library.card_index ALTER COLUMN card_index_id SET DEFAULT nextval('library."сard_Index_сard_Index_id_seq"'::regclass);
 H   ALTER TABLE library.card_index ALTER COLUMN card_index_id DROP DEFAULT;
       library          postgres    false    222    221    222            �           2604    122978    copy copy_id    DEFAULT     n   ALTER TABLE ONLY library.copy ALTER COLUMN copy_id SET DEFAULT nextval('library.copy_copy_id_seq'::regclass);
 <   ALTER TABLE library.copy ALTER COLUMN copy_id DROP DEFAULT;
       library          postgres    false    223    224    224            �           2604    122985    copy_storage copy_storage_id    DEFAULT     �   ALTER TABLE ONLY library.copy_storage ALTER COLUMN copy_storage_id SET DEFAULT nextval('library.copy_storage_copy_storage_id_seq'::regclass);
 L   ALTER TABLE library.copy_storage ALTER COLUMN copy_storage_id DROP DEFAULT;
       library          postgres    false    225    226    226            �           2604    123754    document document_id    DEFAULT     ~   ALTER TABLE ONLY library.document ALTER COLUMN document_id SET DEFAULT nextval('library.document_document_id_seq'::regclass);
 D   ALTER TABLE library.document ALTER COLUMN document_id DROP DEFAULT;
       library          postgres    false    247    246    247            �           2604    123027    employee employee_id    DEFAULT     ~   ALTER TABLE ONLY library.employee ALTER COLUMN employee_id SET DEFAULT nextval('library.employee_employee_id_seq'::regclass);
 D   ALTER TABLE library.employee ALTER COLUMN employee_id DROP DEFAULT;
       library          postgres    false    237    238    238            �           2604    122963    incoming incoming_id    DEFAULT     ~   ALTER TABLE ONLY library.incoming ALTER COLUMN incoming_id SET DEFAULT nextval('library.incoming_incoming_id_seq'::regclass);
 D   ALTER TABLE library.incoming ALTER COLUMN incoming_id DROP DEFAULT;
       library          postgres    false    220    219    220            �           2604    122999    publisher publisher_id    DEFAULT     �   ALTER TABLE ONLY library.publisher ALTER COLUMN publisher_id SET DEFAULT nextval('library.publisher_publisher_id_seq'::regclass);
 F   ALTER TABLE library.publisher ALTER COLUMN publisher_id DROP DEFAULT;
       library          postgres    false    230    229    230            �           2604    123006    reader reader_id    DEFAULT     v   ALTER TABLE ONLY library.reader ALTER COLUMN reader_id SET DEFAULT nextval('library.reader_reader_id_seq'::regclass);
 @   ALTER TABLE library.reader ALTER COLUMN reader_id DROP DEFAULT;
       library          postgres    false    232    231    232            �           2604    123013 &   registered_reader registered_reader_id    DEFAULT     �   ALTER TABLE ONLY library.registered_reader ALTER COLUMN registered_reader_id SET DEFAULT nextval('library.registered_reader_registered_reader_id_seq'::regclass);
 V   ALTER TABLE library.registered_reader ALTER COLUMN registered_reader_id DROP DEFAULT;
       library          postgres    false    234    233    234            �           2604    123724    registering registering_id    DEFAULT     �   ALTER TABLE ONLY library.registering ALTER COLUMN registering_id SET DEFAULT nextval('library.registering_registering_id_seq'::regclass);
 J   ALTER TABLE library.registering ALTER COLUMN registering_id DROP DEFAULT;
       library          postgres    false    245    244    245            �           2604    122992    storage storage_id    DEFAULT     z   ALTER TABLE ONLY library.storage ALTER COLUMN storage_id SET DEFAULT nextval('library.storage_storage_id_seq'::regclass);
 B   ALTER TABLE library.storage ALTER COLUMN storage_id DROP DEFAULT;
       library          postgres    false    228    227    228            �           2604    123467    subcription_audit id    DEFAULT     ~   ALTER TABLE ONLY library.subcription_audit ALTER COLUMN id SET DEFAULT nextval('library.subcription_audit_id_seq'::regclass);
 D   ALTER TABLE library.subcription_audit ALTER COLUMN id DROP DEFAULT;
       library          postgres    false    243    242    243            �           2604    123020    subscription subscription_id    DEFAULT     �   ALTER TABLE ONLY library.subscription ALTER COLUMN subscription_id SET DEFAULT nextval('library.subscription_subscription_id_seq'::regclass);
 L   ALTER TABLE library.subscription ALTER COLUMN subscription_id DROP DEFAULT;
       library          postgres    false    236    235    236            �           2604    122956 $   supplier_invoice supplier_invoice_id    DEFAULT     �   ALTER TABLE ONLY library.supplier_invoice ALTER COLUMN supplier_invoice_id SET DEFAULT nextval('library.supplier_invoice_supplier_invoice_id_seq'::regclass);
 T   ALTER TABLE library.supplier_invoice ALTER COLUMN supplier_invoice_id DROP DEFAULT;
       library          postgres    false    217    218    218            �          0    123114 	   affiliate 
   TABLE DATA           R   COPY library.affiliate (affiliate_id, affiliate_name, address, level) FROM stdin;
    library          postgres    false    240   ��       �          0    122946    book 
   TABLE DATA           d   COPY library.book (book_id, title, volume_number, author, field_of_knowledge, language) FROM stdin;
    library          postgres    false    216   z�       �          0    122968 
   card_index 
   TABLE DATA           �   COPY library.card_index (card_index_id, book_id, publisher_id, publisher_type, translator, publish_year, copies_count, compiler) FROM stdin;
    library          postgres    false    222   A�       �          0    122975    copy 
   TABLE DATA           O   COPY library.copy (copy_id, status, retention_period, incoming_id) FROM stdin;
    library          postgres    false    224   ��       �          0    122982    copy_storage 
   TABLE DATA           k   COPY library.copy_storage (copy_storage_id, copy_id, storage_id, status, date_start, date_end) FROM stdin;
    library          postgres    false    226   ��       �          0    123751    document 
   TABLE DATA           U   COPY library.document (document_id, employee_id, copy_id, document_type) FROM stdin;
    library          postgres    false    247   4�       �          0    123024    employee 
   TABLE DATA           s   COPY library.employee (employee_id, employee_full_name, affiliate_id, "position", email, phone_number) FROM stdin;
    library          postgres    false    238   h�       �          0    122960    incoming 
   TABLE DATA           Z   COPY library.incoming (incoming_id, supplier_invoice_id, date, card_index_id) FROM stdin;
    library          postgres    false    220   ��       �          0    122996 	   publisher 
   TABLE DATA           H   COPY library.publisher (publisher_id, publisher_name, city) FROM stdin;
    library          postgres    false    230   8�       �          0    123003    reader 
   TABLE DATA           n   COPY library.reader (reader_id, passport_details, reader_full_name, email, address, phone_number) FROM stdin;
    library          postgres    false    232   ��       �          0    123010    registered_reader 
   TABLE DATA           t   COPY library.registered_reader (registered_reader_id, reader_id, subscription_id, date_start, date_end) FROM stdin;
    library          postgres    false    234           �          0    123721    registering 
   TABLE DATA           V   COPY library.registering (registering_id, incoming_id, employee_id, date) FROM stdin;
    library          postgres    false    245   @      �          0    122989    storage 
   TABLE DATA           V   COPY library.storage (storage_id, shelf_number, rack_number, room_number) FROM stdin;
    library          postgres    false    228   ]      �          0    123464    subcription_audit 
   TABLE DATA           �   COPY library.subcription_audit (id, operation, operation_timestamp, subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty) FROM stdin;
    library          postgres    false    243   R      �          0    123017    subscription 
   TABLE DATA           �   COPY library.subscription (subscription_id, employee_id, copy_id, date_subscribed, date_return, date_real_return, status, penalty) FROM stdin;
    library          postgres    false    236   �      �          0    122953    supplier_invoice 
   TABLE DATA           U   COPY library.supplier_invoice (supplier_invoice_id, supplier_name, date) FROM stdin;
    library          postgres    false    218   C      �           0    0    affiliate_affiliate_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('library.affiliate_affiliate_id_seq', 114, true);
          library          postgres    false    239            �           0    0    book_book_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('library.book_book_id_seq', 31, true);
          library          postgres    false    215            �           0    0    copy_copy_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('library.copy_copy_id_seq', 60, true);
          library          postgres    false    223            �           0    0     copy_storage_copy_storage_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('library.copy_storage_copy_storage_id_seq', 30, true);
          library          postgres    false    225            �           0    0    document_document_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('library.document_document_id_seq', 1, true);
          library          postgres    false    246            �           0    0    employee_employee_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('library.employee_employee_id_seq', 15, true);
          library          postgres    false    237            �           0    0    incoming_incoming_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('library.incoming_incoming_id_seq', 19, true);
          library          postgres    false    219            �           0    0    publisher_publisher_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('library.publisher_publisher_id_seq', 21, true);
          library          postgres    false    229            �           0    0    reader_reader_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('library.reader_reader_id_seq', 12, true);
          library          postgres    false    231            �           0    0 *   registered_reader_registered_reader_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('library.registered_reader_registered_reader_id_seq', 29, true);
          library          postgres    false    233            �           0    0    registering_registering_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('library.registering_registering_id_seq', 1, false);
          library          postgres    false    244            �           0    0    storage_storage_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('library.storage_storage_id_seq', 90, true);
          library          postgres    false    227            �           0    0    subcription_audit_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('library.subcription_audit_id_seq', 3, true);
          library          postgres    false    242            �           0    0     subscription_subscription_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('library.subscription_subscription_id_seq', 36, true);
          library          postgres    false    235            �           0    0 (   supplier_invoice_supplier_invoice_id_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('library.supplier_invoice_supplier_invoice_id_seq', 10, true);
          library          postgres    false    217            �           0    0    сard_Index_сard_Index_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('library."сard_Index_сard_Index_id_seq"', 19, true);
          library          postgres    false    221                        2606    123119    affiliate affiliate_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY library.affiliate
    ADD CONSTRAINT affiliate_pkey PRIMARY KEY (affiliate_id);
 C   ALTER TABLE ONLY library.affiliate DROP CONSTRAINT affiliate_pkey;
       library            postgres    false    240            �           2606    122951    book book_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY library.book
    ADD CONSTRAINT book_pkey PRIMARY KEY (book_id);
 9   ALTER TABLE ONLY library.book DROP CONSTRAINT book_pkey;
       library            postgres    false    216            �           2606    123181    card_index ch_copies_count    CHECK CONSTRAINT     i   ALTER TABLE library.card_index
    ADD CONSTRAINT ch_copies_count CHECK ((copies_count >= 0)) NOT VALID;
 @   ALTER TABLE library.card_index DROP CONSTRAINT ch_copies_count;
       library          postgres    false    222    222            �           2606    123170    incoming ch_date    CHECK CONSTRAINT     [   ALTER TABLE library.incoming
    ADD CONSTRAINT ch_date CHECK ((date <= now())) NOT VALID;
 6   ALTER TABLE library.incoming DROP CONSTRAINT ch_date;
       library          postgres    false    220    220            �           2606    123177    supplier_invoice ch_date    CHECK CONSTRAINT     c   ALTER TABLE library.supplier_invoice
    ADD CONSTRAINT ch_date CHECK ((date <= now())) NOT VALID;
 >   ALTER TABLE library.supplier_invoice DROP CONSTRAINT ch_date;
       library          postgres    false    218    218            �           2606    123162    registered_reader ch_date_end    CHECK CONSTRAINT     p   ALTER TABLE library.registered_reader
    ADD CONSTRAINT ch_date_end CHECK ((date_end > date_start)) NOT VALID;
 C   ALTER TABLE library.registered_reader DROP CONSTRAINT ch_date_end;
       library          postgres    false    234    234    234    234            �           2606    123169    copy_storage ch_date_end    CHECK CONSTRAINT     k   ALTER TABLE library.copy_storage
    ADD CONSTRAINT ch_date_end CHECK ((date_end > date_start)) NOT VALID;
 >   ALTER TABLE library.copy_storage DROP CONSTRAINT ch_date_end;
       library          postgres    false    226    226    226    226            �           2606    123159     subscription ch_date_real_return    CHECK CONSTRAINT     �   ALTER TABLE library.subscription
    ADD CONSTRAINT ch_date_real_return CHECK (((date_real_return IS NULL) OR (date_real_return > date_subscribed))) NOT VALID;
 F   ALTER TABLE library.subscription DROP CONSTRAINT ch_date_real_return;
       library          postgres    false    236    236    236    236            �           2606    123158    subscription ch_date_return    CHECK CONSTRAINT     v   ALTER TABLE library.subscription
    ADD CONSTRAINT ch_date_return CHECK ((date_return > date_subscribed)) NOT VALID;
 A   ALTER TABLE library.subscription DROP CONSTRAINT ch_date_return;
       library          postgres    false    236    236    236    236            �           2606    123161    registered_reader ch_date_start    CHECK CONSTRAINT     p   ALTER TABLE library.registered_reader
    ADD CONSTRAINT ch_date_start CHECK ((date_start <= now())) NOT VALID;
 E   ALTER TABLE library.registered_reader DROP CONSTRAINT ch_date_start;
       library          postgres    false    234    234            �           2606    123168    copy_storage ch_date_start    CHECK CONSTRAINT     k   ALTER TABLE library.copy_storage
    ADD CONSTRAINT ch_date_start CHECK ((date_start <= now())) NOT VALID;
 @   ALTER TABLE library.copy_storage DROP CONSTRAINT ch_date_start;
       library          postgres    false    226    226            �           2606    123160    subscription ch_date_subscribed    CHECK CONSTRAINT     u   ALTER TABLE library.subscription
    ADD CONSTRAINT ch_date_subscribed CHECK ((date_subscribed <= now())) NOT VALID;
 E   ALTER TABLE library.subscription DROP CONSTRAINT ch_date_subscribed;
       library          postgres    false    236    236            �           2606    123191    reader ch_phone_number    CHECK CONSTRAINT     d   ALTER TABLE library.reader
    ADD CONSTRAINT ch_phone_number CHECK ((phone_number > 0)) NOT VALID;
 <   ALTER TABLE library.reader DROP CONSTRAINT ch_phone_number;
       library          postgres    false    232    232            �           2606    123205    employee ch_phone_number    CHECK CONSTRAINT     f   ALTER TABLE library.employee
    ADD CONSTRAINT ch_phone_number CHECK ((phone_number > 0)) NOT VALID;
 >   ALTER TABLE library.employee DROP CONSTRAINT ch_phone_number;
       library          postgres    false    238    238            �           2606    123180    card_index ch_publish_year    CHECK CONSTRAINT     h   ALTER TABLE library.card_index
    ADD CONSTRAINT ch_publish_year CHECK ((publish_year > 0)) NOT VALID;
 @   ALTER TABLE library.card_index DROP CONSTRAINT ch_publish_year;
       library          postgres    false    222    222            �           2606    123252    card_index ch_publisher_type    CHECK CONSTRAINT     �   ALTER TABLE library.card_index
    ADD CONSTRAINT ch_publisher_type CHECK (((publisher_type)::text = ANY ((ARRAY['Электронный'::character varying, 'Печатный'::character varying])::text[]))) NOT VALID;
 B   ALTER TABLE library.card_index DROP CONSTRAINT ch_publisher_type;
       library          postgres    false    222    222            �           2606    123174    storage ch_rack_number    CHECK CONSTRAINT     c   ALTER TABLE library.storage
    ADD CONSTRAINT ch_rack_number CHECK ((rack_number > 0)) NOT VALID;
 <   ALTER TABLE library.storage DROP CONSTRAINT ch_rack_number;
       library          postgres    false    228    228            �           2606    123175    storage ch_room_number    CHECK CONSTRAINT     c   ALTER TABLE library.storage
    ADD CONSTRAINT ch_room_number CHECK ((room_number > 0)) NOT VALID;
 <   ALTER TABLE library.storage DROP CONSTRAINT ch_room_number;
       library          postgres    false    228    228            �           2606    123173    storage ch_shelf_number    CHECK CONSTRAINT     e   ALTER TABLE library.storage
    ADD CONSTRAINT ch_shelf_number CHECK ((shelf_number > 0)) NOT VALID;
 =   ALTER TABLE library.storage DROP CONSTRAINT ch_shelf_number;
       library          postgres    false    228    228            �           2606    123166    copy ch_status    CHECK CONSTRAINT     �   ALTER TABLE library.copy
    ADD CONSTRAINT ch_status CHECK (((status)::text = ANY ((ARRAY['выданный'::character varying, 'возвращенный'::character varying, 'просроченный'::character varying])::text[]))) NOT VALID;
 4   ALTER TABLE library.copy DROP CONSTRAINT ch_status;
       library          postgres    false    224    224            �           2606    123167    copy_storage ch_status    CHECK CONSTRAINT       ALTER TABLE library.copy_storage
    ADD CONSTRAINT ch_status CHECK (((status)::text = ANY (ARRAY[('выданный'::character varying)::text, ('возвращенный'::character varying)::text, ('просроченный'::character varying)::text]))) NOT VALID;
 <   ALTER TABLE library.copy_storage DROP CONSTRAINT ch_status;
       library          postgres    false    226    226            �           2606    123176    subscription ch_status    CHECK CONSTRAINT     �   ALTER TABLE library.subscription
    ADD CONSTRAINT ch_status CHECK (((status)::text = ANY ((ARRAY['активный'::character varying, 'неактивный'::character varying, 'истекший'::character varying])::text[]))) NOT VALID;
 <   ALTER TABLE library.subscription DROP CONSTRAINT ch_status;
       library          postgres    false    236    236            �           2606    123165    book ch_volume_number    CHECK CONSTRAINT     d   ALTER TABLE library.book
    ADD CONSTRAINT ch_volume_number CHECK ((volume_number > 0)) NOT VALID;
 ;   ALTER TABLE library.book DROP CONSTRAINT ch_volume_number;
       library          postgres    false    216    216            �           2606    122980    copy copy_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY library.copy
    ADD CONSTRAINT copy_pkey PRIMARY KEY (copy_id);
 9   ALTER TABLE ONLY library.copy DROP CONSTRAINT copy_pkey;
       library            postgres    false    224            �           2606    122987    copy_storage copy_storage_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY library.copy_storage
    ADD CONSTRAINT copy_storage_pkey PRIMARY KEY (copy_storage_id);
 I   ALTER TABLE ONLY library.copy_storage DROP CONSTRAINT copy_storage_pkey;
       library            postgres    false    226                       2606    123756    document document_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY library.document
    ADD CONSTRAINT document_pkey PRIMARY KEY (document_id);
 A   ALTER TABLE ONLY library.document DROP CONSTRAINT document_pkey;
       library            postgres    false    247            �           2606    123029    employee employee_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY library.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);
 A   ALTER TABLE ONLY library.employee DROP CONSTRAINT employee_pkey;
       library            postgres    false    238            �           2606    122965    incoming incoming_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY library.incoming
    ADD CONSTRAINT incoming_pkey PRIMARY KEY (incoming_id);
 A   ALTER TABLE ONLY library.incoming DROP CONSTRAINT incoming_pkey;
       library            postgres    false    220            �           2606    123001    publisher publisher_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY library.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id);
 C   ALTER TABLE ONLY library.publisher DROP CONSTRAINT publisher_pkey;
       library            postgres    false    230            �           2606    123008    reader reader_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY library.reader
    ADD CONSTRAINT reader_pkey PRIMARY KEY (reader_id);
 =   ALTER TABLE ONLY library.reader DROP CONSTRAINT reader_pkey;
       library            postgres    false    232            �           2606    123015 (   registered_reader registered_reader_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY library.registered_reader
    ADD CONSTRAINT registered_reader_pkey PRIMARY KEY (registered_reader_id);
 S   ALTER TABLE ONLY library.registered_reader DROP CONSTRAINT registered_reader_pkey;
       library            postgres    false    234                       2606    123727    registering registering_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY library.registering
    ADD CONSTRAINT registering_pkey PRIMARY KEY (registering_id);
 G   ALTER TABLE ONLY library.registering DROP CONSTRAINT registering_pkey;
       library            postgres    false    245            �           2606    122994    storage storage_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY library.storage
    ADD CONSTRAINT storage_pkey PRIMARY KEY (storage_id);
 ?   ALTER TABLE ONLY library.storage DROP CONSTRAINT storage_pkey;
       library            postgres    false    228                       2606    123470 (   subcription_audit subcription_audit_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY library.subcription_audit
    ADD CONSTRAINT subcription_audit_pkey PRIMARY KEY (id);
 S   ALTER TABLE ONLY library.subcription_audit DROP CONSTRAINT subcription_audit_pkey;
       library            postgres    false    243            �           2606    123022    subscription subscription_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY library.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (subscription_id);
 I   ALTER TABLE ONLY library.subscription DROP CONSTRAINT subscription_pkey;
       library            postgres    false    236            �           2606    122958 &   supplier_invoice supplier_invoice_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY library.supplier_invoice
    ADD CONSTRAINT supplier_invoice_pkey PRIMARY KEY (supplier_invoice_id);
 Q   ALTER TABLE ONLY library.supplier_invoice DROP CONSTRAINT supplier_invoice_pkey;
       library            postgres    false    218            �           2606    123203    book un_book 
   CONSTRAINT     X   ALTER TABLE ONLY library.book
    ADD CONSTRAINT un_book UNIQUE (title, volume_number);
 7   ALTER TABLE ONLY library.book DROP CONSTRAINT un_book;
       library            postgres    false    216    216                       2606    123729    registering un_registering 
   CONSTRAINT     j   ALTER TABLE ONLY library.registering
    ADD CONSTRAINT un_registering UNIQUE (employee_id, incoming_id);
 E   ALTER TABLE ONLY library.registering DROP CONSTRAINT un_registering;
       library            postgres    false    245    245            �           2606    123183    storage un_storage 
   CONSTRAINT     p   ALTER TABLE ONLY library.storage
    ADD CONSTRAINT un_storage UNIQUE (shelf_number, rack_number, room_number);
 =   ALTER TABLE ONLY library.storage DROP CONSTRAINT un_storage;
       library            postgres    false    228    228    228            �           2606    122973    card_index сard_Index_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY library.card_index
    ADD CONSTRAINT "сard_Index_pkey" PRIMARY KEY (card_index_id);
 H   ALTER TABLE ONLY library.card_index DROP CONSTRAINT "сard_Index_pkey";
       library            postgres    false    222            �           1259    123267    idx_employee_employee_full_name    INDEX     c   CREATE INDEX idx_employee_employee_full_name ON library.employee USING btree (employee_full_name);
 4   DROP INDEX library.idx_employee_employee_full_name;
       library            postgres    false    238            �           1259    123268    idx_subscription_status_date    INDEX     j   CREATE INDEX idx_subscription_status_date ON library.subscription USING btree (status, date_real_return);
 1   DROP INDEX library.idx_subscription_status_date;
       library            postgres    false    236    236            �           2618    123256    debtors _RETURN    RULE     �  CREATE OR REPLACE VIEW library.debtors AS
 SELECT r.reader_id,
    r.reader_full_name,
    r.address,
    r.phone_number,
    count(s.subscription_id) AS overdue_subscriptions
   FROM ((library.reader r
     JOIN library.registered_reader rr ON ((r.reader_id = rr.reader_id)))
     JOIN library.subscription s ON ((s.subscription_id = rr.subscription_id)))
  WHERE (((s.status)::text = 'активный'::text) AND (s.date_real_return IS NULL))
  GROUP BY r.reader_id;
 �   CREATE OR REPLACE VIEW library.debtors AS
SELECT
    NULL::integer AS reader_id,
    NULL::character varying(45) AS reader_full_name,
    NULL::character varying(45) AS address,
    NULL::bigint AS phone_number,
    NULL::bigint AS overdue_subscriptions;
       library          postgres    false    232    232    232    236    232    236    236    3318    234    234    241                       2620    123472 %   subscription trigger_log_subscription    TRIGGER     �   CREATE TRIGGER trigger_log_subscription AFTER INSERT OR DELETE OR UPDATE ON library.subscription FOR EACH ROW EXECUTE FUNCTION library.log_subcription();
 ?   DROP TRIGGER trigger_log_subscription ON library.subscription;
       library          postgres    false    236    263                       2606    123120    employee affiliate_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.employee
    ADD CONSTRAINT affiliate_id_fkey FOREIGN KEY (affiliate_id) REFERENCES library.affiliate(affiliate_id) ON UPDATE CASCADE NOT VALID;
 E   ALTER TABLE ONLY library.employee DROP CONSTRAINT affiliate_id_fkey;
       library          postgres    false    240    238    3328                       2606    123063    card_index book_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.card_index
    ADD CONSTRAINT book_id_fkey FOREIGN KEY (book_id) REFERENCES library.book(book_id) ON UPDATE CASCADE NOT VALID;
 B   ALTER TABLE ONLY library.card_index DROP CONSTRAINT book_id_fkey;
       library          postgres    false    3298    216    222            	           2606    123745    incoming card_index_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.incoming
    ADD CONSTRAINT card_index_id_fkey FOREIGN KEY (card_index_id) REFERENCES library.card_index(card_index_id) ON UPDATE CASCADE NOT VALID;
 F   ALTER TABLE ONLY library.incoming DROP CONSTRAINT card_index_id_fkey;
       library          postgres    false    220    3306    222                       2606    123762    document ch_copy_id    FK CONSTRAINT     �   ALTER TABLE ONLY library.document
    ADD CONSTRAINT ch_copy_id FOREIGN KEY (copy_id) REFERENCES library.copy(copy_id) ON UPDATE CASCADE NOT VALID;
 >   ALTER TABLE ONLY library.document DROP CONSTRAINT ch_copy_id;
       library          postgres    false    3308    224    247                       2606    123757    document ch_employee_id    FK CONSTRAINT     �   ALTER TABLE ONLY library.document
    ADD CONSTRAINT ch_employee_id FOREIGN KEY (employee_id) REFERENCES library.employee(employee_id) ON UPDATE CASCADE NOT VALID;
 B   ALTER TABLE ONLY library.document DROP CONSTRAINT ch_employee_id;
       library          postgres    false    238    247    3325                       2606    123083    copy_storage copy_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.copy_storage
    ADD CONSTRAINT copy_id_fkey FOREIGN KEY (copy_id) REFERENCES library.copy(copy_id) ON UPDATE CASCADE NOT VALID;
 D   ALTER TABLE ONLY library.copy_storage DROP CONSTRAINT copy_id_fkey;
       library          postgres    false    226    3308    224                       2606    123098    subscription copy_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.subscription
    ADD CONSTRAINT copy_id_fkey FOREIGN KEY (copy_id) REFERENCES library.copy(copy_id) ON UPDATE CASCADE NOT VALID;
 D   ALTER TABLE ONLY library.subscription DROP CONSTRAINT copy_id_fkey;
       library          postgres    false    236    3308    224                       2606    123093    subscription employee_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.subscription
    ADD CONSTRAINT employee_id_fkey FOREIGN KEY (employee_id) REFERENCES library.employee(employee_id) ON UPDATE CASCADE NOT VALID;
 H   ALTER TABLE ONLY library.subscription DROP CONSTRAINT employee_id_fkey;
       library          postgres    false    236    3325    238                       2606    123735    registering fk_employee_id    FK CONSTRAINT     �   ALTER TABLE ONLY library.registering
    ADD CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES library.employee(employee_id) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY library.registering DROP CONSTRAINT fk_employee_id;
       library          postgres    false    3325    245    238                       2606    123730    registering fk_incoming_id    FK CONSTRAINT     �   ALTER TABLE ONLY library.registering
    ADD CONSTRAINT fk_incoming_id FOREIGN KEY (incoming_id) REFERENCES library.incoming(incoming_id) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY library.registering DROP CONSTRAINT fk_incoming_id;
       library          postgres    false    245    220    3304                       2606    123740    copy fk_incoming_id    FK CONSTRAINT     �   ALTER TABLE ONLY library.copy
    ADD CONSTRAINT fk_incoming_id FOREIGN KEY (incoming_id) REFERENCES library.incoming(incoming_id) ON UPDATE CASCADE NOT VALID;
 >   ALTER TABLE ONLY library.copy DROP CONSTRAINT fk_incoming_id;
       library          postgres    false    224    220    3304                       2606    123068    card_index publisher_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.card_index
    ADD CONSTRAINT publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES library.publisher(publisher_id) ON UPDATE CASCADE NOT VALID;
 G   ALTER TABLE ONLY library.card_index DROP CONSTRAINT publisher_id_fkey;
       library          postgres    false    3316    230    222                       2606    123103     registered_reader reader_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.registered_reader
    ADD CONSTRAINT reader_id_fkey FOREIGN KEY (reader_id) REFERENCES library.reader(reader_id) ON UPDATE CASCADE NOT VALID;
 K   ALTER TABLE ONLY library.registered_reader DROP CONSTRAINT reader_id_fkey;
       library          postgres    false    234    3318    232                       2606    123088    copy_storage storage_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.copy_storage
    ADD CONSTRAINT storage_id_fkey FOREIGN KEY (storage_id) REFERENCES library.storage(storage_id) ON UPDATE CASCADE NOT VALID;
 G   ALTER TABLE ONLY library.copy_storage DROP CONSTRAINT storage_id_fkey;
       library          postgres    false    226    3312    228                       2606    123108 &   registered_reader subscription_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.registered_reader
    ADD CONSTRAINT subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES library.subscription(subscription_id) ON UPDATE CASCADE NOT VALID;
 Q   ALTER TABLE ONLY library.registered_reader DROP CONSTRAINT subscription_id_fkey;
       library          postgres    false    3323    236    234            
           2606    123053 !   incoming supplier_invoice_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY library.incoming
    ADD CONSTRAINT supplier_invoice_id_fkey FOREIGN KEY (supplier_invoice_id) REFERENCES library.supplier_invoice(supplier_invoice_id) ON UPDATE CASCADE NOT VALID;
 L   ALTER TABLE ONLY library.incoming DROP CONSTRAINT supplier_invoice_id_fkey;
       library          postgres    false    218    3302    220            �   �  x��Z�R�H}6_�H�,��/�s�l���@����إ*yI�8��/�����.�t�Z
n?PF���:ӧ�̱���Rwj	s��ǣZ����s��ߨ8�R��W˗cu����Z虚�=�`f���_�������]U�!�;���g6�#\��`�����I� ��*��p�N�	햱^�㑺�!uk"@��;��q�wm�Uԙ���B���ױ��'8x���+C/Ե�Q�D=ٛ\��#Z��Z�"����w�
��Q�R�~b�6q`l�t�>��_Uܤ;�q�)@����8�pOݨ)���{�h�|�s3���1��|h�Ѷ��@̽u֑�uΔ6��[�1ԯI�]�3R"S��)���Gp��1�ͷ�|�t�+#�2�0Z��[�w�5�r��LH�9O!���Ҿz��͝Tu�������¦y_���4�&c��jzJ��h�������'S$� �B!%�0�4U�_��3�p�|��>ʍm��f�@c8{U����j���2}��9T�B�&���SO�@�E��˄|����qk�^l�9Y��^��[�yW��'$<��#H��T�J��ؔ��7�R�f�����Q�:e�zi��,�k����?%<M�J ���3/��:y3+[��s���Cu��-g�ʄ��)CΏz�,��;����)GT8sW�Mu4�ެvM'qRe��{2�=�p��i�2��\�g_���?���l��� o�O�Q
�~-� <���TN��
�������?��Rr��gV����#ZB%v�.��>cY
��n����a�zTɊz�1D�Em���f�$�/!CZ�����QLЊ|�,dK%�A@Y�жK2UO�'��&Ԇ,b\&7D�G,O]�4PS�s1<Ś�����.���+��fhֺ�ig���8Ҷ$S�Ѡ��,{"�"��X45��'O�;`3d�K�*o�d򫲈�+VLU�]Kx�ʶ�!f�J�L4B���L}�Nl��������1CL�d�7��,E]��W�^b��~�ԿoB�6f8ڭ��TYbcv�JS_��N3�)&ޔD�!f�;daB���a*VLC�&VG��W�bj��)&� ND\&�r"�1�"L�M&��d�&6�7t��F-����L�~D=&2����DtM*�1�E;q�PK�=&��Rq�	)�T�b"
!3�h9nh2!S ݂�Dȟ
zLd��m�cB�6ۚ�Dv����D�"���2Y�)��h�[Lt:E,&Ԅ31���OP����-&��-���/l1�9�-&�3���D�V�b"�&r��V2q��;��;L����&��D�b"�1����L64���\&��&�6)�`��)�8m�h"�2�;M�U����a�6���{��9fو�{M�q�(�2/5�n&�N�'oqÉ���������V�q?      �   �  x��WMOg>/��r.bm�oU���*R�u��jQk�q$JT�fҤ�&��%���H����5a��yf�uP0��9`���3��<��R ;2���9I�%��A)��ґ����F��-~�౓�%ʚ�:����!}I�75K���PO�����a �r2���S*ܑ4�WI
�H�0�4�m�k����H�G�?\rxh��3�m���6���cbϚN^�����ل����C�����i���Y4fG��$::�\` ��gtr�i]���|p��ܪ�U�~v�W+�V~����2�Ep��G.k8<SUD����7��t�ou�E���\��� Ǒ�H&d5p�UHq�7o�MtX�Z�R�K�J�Sĭ#��L,�"��g��R��� &|Ud���肨�s����ۈO��Fr¬��؍�tj��y�Q�H�J���ޙ��֧�N5t����Z,�LGP�0�x�$1��)��Cr�� A=�E̪�e�Ԗ&���3���>B�P����,]V)`�����]*դ��\�R.��a��Q���8E�aζ�4�k�j�i3��<ȞZ�m��!U�m��=��.-���������ڃo�����Ҁ�mj ��̓��v-��4�N��9Ѧ�V{2ӆ���P����!�-�6����]���;FN齌�� \Z���p^ �:JƆ�������00]�e,���i��q��m��k��kB��;Ca�&6�� ��GK�>]?�a��4��a��"��
ose�W�2u�����m?A�uiUʆ1n}���Z?aj�K>�����q��CR��pζ�>3KZ캱5���gXk)Q������iG�%5�L�A��>h�_@���U�sr�}1*���n��_�J���W,�8Wz�51��y�6�Ғ'��ʽ�j���!|�J�uPkr�dtL�[Q�R-֦U�-��]W؏-�R��鎔�n����~`��<��m*���+_W����V*��j��e*���1و�%�Eڱ�ٳ�g����oQ��Ŀ��ز�pf��ԲU� ��YۅMV^�?�L���gG#�Hg}����?��t�fu��ͼ�؎�[V[���o탯���-�Xm�7�돍�ni��`S{�Uh#_���+�W�˪1Ig��P��2���fu1�t���/�4K�j'v�]�VC\���w�dK_MOMM�4�      �   c  x�}TY��@��>�Ou���0@�)HC&i�!��h�ə`	��7ʫj�1Q���W�GΉ�o>p�UX����:|�=��q�.x�@�a��O��4%���J~J�MJN��r��}�&XK..^�%����Ў&6Zl������{3"�2�~�x3 ��["��	,M|��$	:Ռɩ\���'�	�o /%> W즔ٞUܩƓS�}��m����Y�XT�.��_��4�>�	9��*���_�a��B�7�~B*I�Qn{�a�p�j2r*C�ܣ�9��	���Z����P�{6��N599�K��2c20B�#�4���={ki�>�)9�!�ߴ�R����Zi��JG��`�&t��x�F���:u����i��?�Vᦝ�N5X���y���	m|L���B�������G��5��M�yd��u����؟[5��s3�s~/K�5�cg�p�q�=y+�AڐĿ������"�,��v��1��]�v�T1�'�k�j��\�dǇ������V�����h�Q���zvi�=p <��)L�w�8A1r��͘��u���۲�i)�)�w�n�u��v��A����0���Mz�۩��+c�?5�o      �   �  x����m1E�b/��zq1�*Ҍ���݂^G!E��<`�ˡt�0�_���e>Ϸ����$��W.WƄ@�~���Z�u>?~����8��x|[�����E91��.,I��xxaNj���H[Hږ����k�C��e��axyX�n�݂c�27��H'h]C"@����('�X(���W'��Q���
�N�5l��(���:�cKE�u0�rH��: �T����0u������ԡj,��Z�b�C���	)^Wj'�+=S����3�81}�Ch�y��x���|���j 5$�5���B�Z壉�Uj�XE�$��]�L��Ǳ���:)�u�L��"{9T4��:r���c9s�e�Hs��.rd�6%Vnqks�"gV���*r�V��&rh5���Dm���"rf�[��"rf���E��nG��&rf�1��D��no"gk36�#���ȑCo۲7�B.s�XD�iI�Xj,"��m�O_ �/��RD      �   n  x���MJ1����2�W���]<��D���".F����ՉZ�'C5M��5��Ph�^NO��=�c;��C4h<�|�9;Be���>ۻE���鱽���Q�i_��y���s�衈$%H���|;!�6s�졌"�̹��
�fk��Ur�zW�T�*�̹V�`���ٷ�}�Z�O����
�3:�T0
��p^>#�Ğt�[�fa�`
�0�E�M؅sX�E8���\�*�2L�\Vpvv�\�Э��E�t���Pk��p��b�������ٺ��B���.z,B���.y,A��q-��e_�Pkyh0�++Pk��0�[<�@��q7��U_�Pkyh0�[=�"�C�]tb���o�Zmr      �   $   x�3�4�/쿰�b��^�qa+W� ��U      �   6  x����N�@�ϻO�'@�8Ο[���*�Na'R99��R���*RU���
�o��؁�V8������~��*��R��n�Mam�B�O�p9\C��K}�A�}&��;	�oƮ��b0��Jv��L�үk{��q�9��?���Ă?��)u"�^|h&t�-�7�ia���/時�����8Z�)r�����?�P���60m�#&�TT�};G_� Ә��`���h�6Xؓ���>�(���7J��@��k3�fԧ��ċ#3̑}�W�n0���٣K���ZV���]�fL_|�u�W�3���'*خ}��[7w#?�=#z �t�E�M"�Ƞ���9l�q����rD��Дl����z��)��\xc�!#�:���ueᒅɅue�n0hOs�>����7Ց
_��7� ð�n���d9�����u�~�#3UI���3�a�]񽣜��>mu��ݖ+�G^`v���E�P��3�C���̑����ĤkK���O� �N��[���W��zR9�}N	uE� 9�>���ݧ؏�QT�|{ �|ā�      �   z   x�MιACј�e������ױt`H�=F_�E�|� "���99��9\X9��9<89��9T��?�=�J��j���j��N�dC��ц&U�-���TM7�o���!��(7x      �   �  x��S[N�@�Ξ"(bys��RDU��/�4%44Mz��1vR��ZP�j��؞��`�7�� 9J�u�<e�C��!� ���>���fm	�W>B�Qc�9C�
Sw����ra�b��ͺ��)�3>�q��i-Xm����m@���P�(0B�"��lzh�c�s��,Q�q�@�jI[g�3��B�+��)�A�	��@�S�����f�o�%}�Gyx�z݈0fՈ�7���}�J?�˦���o,
nW�#ߥ;j<�E
�X�i{%�ט���6�n��u"��J
�Y��8U��q�����ύ����`֡"iGǩ\l�2O-��G�a��e����o��#�1R���7�s�=�1�i4�"k��Y���wG읫��.O�=���ɚ�-�gm!��3Ƌ䞨�*!���c>�"�      �     x�u�KnA��=��k�{^���X!v,ٌ�(X�=�G��� @"((��BB����q�عB������GcM?�뫿�jsƅ�0����O��=�S�ug�8���#+$��`;}�T땴�:�2}���P�p���q��W��|��!|��_�Sq���w}��ȴm�|�g)t=�o���&��9ڲ��i����=��`��r��K�C}G,�[��H&�0�2�P�k�ԇ�r���]^!�fy'[C�q:9	f?�ɕ�4��.�c���=�i��w\�^'�r�ǐy��;pX�Zn@}�e�KZ�"��G1�@�`��؜��1KXN�d�Ds?Z�R���A��H�Ad���s���A�dNq>���x��8!�=�$
�h��~�1��J�!��C�~A�zV_���� <���M[�;�O�q�Rp�=��B�Y.tr�T�5q�c��`�{f�;wy��'m������>� Yl܈:Ȫ��,���+�������|(z�Cv���t��Q��ֻZ��\���@��ap�_�5�� �|&���d{�QLD�T<�Àm�Ɔ"=V7(� Wmg�Ǯle��3��!���O��;��U̒:p�p?�TQasa�j0����4W�O~�9�V��*I�A3���=Wr	�{�;��ť�ПC{��Tt�qĞU�ڋ���2�ϓ�դ\)5Z�\�%�E�Q�ēyt��z����dĥi8H�C%E �5W͚tHcT�Kn�.�;���A�������*��%8k������A�p���M ��J�B����8�����      �     x�MR˱�0;�^�d;�^^�u,rv�G9�b0HQ�H���������p�ވ��u��F��Pm�m6�7$f���F1�͸�jD��̾�E�j3��4���<������	��3!eU���4�5�-�Nt+�>,�OQ���ԻĲ��)Jr}ZХ�j.6q�3}�[�Qz�z�T<��7{�u�8H0ܰb��@�1+H���aEIi��w�Iy�cZ�R��ѷs��P6�v�,f[��ҡ#�Sp�DM��e_f��f��xҏ�?3� �Y��      �      x������ � �      �   �   x�5͹�C1�P�̖x����XH"j�A��j��{�4~�V��o����J��.�n���=eޭ���X�UZ��C
�J��E��j-M�T�ij��F��j��F��t5Rm���j��F��j��62�H���F��j��F��j���T#�V��F��j��F��j+K�T�Yj��F��j��F��l5R�d��j��F��j��vr�H�'G�T#�H5R�T#�H�'�ړ�_� -��      �   r   x�3���v
�4202�50�52Q0��26�26�3644���46�4B�
(�Č�㼰�®�Mv\�ta���;�b\F��.�!�d�5弰��Vlvs�����֎=... pU      �   _  x��U�i�0�VvI�d;q��7M�L)����ۨ���R8��H�G�-[�rP�8�Èpy��V�o/�������~�)���IbG�@By�$i���, �<�òK�%+H(o5��)l	�m&�:�` �F�pW1�'BM��������eJ�aMUES�z��Xa��?�܀��1?��J$���I&���+Jb�A�Rn��;5�*ϼTO�6K���f��]���1V��Vx�:�z��ͫ��x�� $TAw��z�N�Q@�� ���h��;���P�yw�	�{���W��{�Z�7@	�A����+8�'�O�ױ��,�^��i��a+      �   �   x�u�I�@E��):�1�rW.t�(1^��T�+���EBcb:�!U��k�±Yj�=*x���
%
�G��x����ga�L�v�E�k\��K����9�9/�i�&�t&����O�?�]����M(�Ҷ�uY�x��Zp*�<S^4�1д�8I���HH�^$F,����Jɯj��ֻ�Ui��uF���d�9��h�����\m��|LD_�pł     