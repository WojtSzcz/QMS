--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-06-16 22:31:26

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 19053)
-- Name: staging; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA staging;


ALTER SCHEMA staging OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 19054)
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- TOC entry 886 (class 1247 OID 19062)
-- Name: detal_typ_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.detal_typ_enum AS ENUM (
    'standardowa_produkcja',
    'prototyp',
    'wznowienie_produkcji'
);


ALTER TYPE public.detal_typ_enum OWNER TO postgres;

--
-- TOC entry 889 (class 1247 OID 19070)
-- Name: dokument_rozliczeniowy_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dokument_rozliczeniowy_enum AS ENUM (
    'korekta',
    'WZ',
    'złom',
    'ZW',
    'ZW złom'
);


ALTER TYPE public.dokument_rozliczeniowy_enum OWNER TO postgres;

--
-- TOC entry 892 (class 1247 OID 19082)
-- Name: miejsce_powstania_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.miejsce_powstania_enum AS ENUM (
    'P',
    'G'
);


ALTER TYPE public.miejsce_powstania_enum OWNER TO postgres;

--
-- TOC entry 895 (class 1247 OID 19088)
-- Name: miejsce_zatrzymania_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.miejsce_zatrzymania_enum AS ENUM (
    'P',
    'M',
    'G'
);


ALTER TYPE public.miejsce_zatrzymania_enum OWNER TO postgres;

--
-- TOC entry 898 (class 1247 OID 19096)
-- Name: opis_problemu_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.opis_problemu_status_enum AS ENUM (
    'w trakcie',
    'zakonczone'
);


ALTER TYPE public.opis_problemu_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 19101)
-- Name: audyt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audyt (
    id integer NOT NULL,
    firma_id integer,
    typ_id smallint NOT NULL,
    data date NOT NULL,
    zakres character varying(255),
    uwagi text,
    termin_wyslania_odpowiedzi date,
    termin_zakonczenia_dzialan date
);


ALTER TABLE public.audyt OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 19106)
-- Name: audyt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audyt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audyt_id_seq OWNER TO postgres;

--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 220
-- Name: audyt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audyt_id_seq OWNED BY public.audyt.id;


--
-- TOC entry 221 (class 1259 OID 19107)
-- Name: detal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detal (
    id integer NOT NULL,
    data_produkcji date,
    kod character varying(50) NOT NULL,
    nazwa_wyrobu character varying(150),
    oznaczenie character varying(100),
    ilosc_zlecenie integer,
    ilosc_niezgodna integer,
    typ public.detal_typ_enum,
    ilosc_uznanych integer,
    ilosc_nieuznanych integer,
    ilosc_nowych_uznanych integer,
    ilosc_nowych_nieuznanych integer,
    ilosc_rozliczona integer,
    ilosc_nieuznanych_naprawionych integer
);


ALTER TABLE public.detal OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 19110)
-- Name: detal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detal_id_seq OWNER TO postgres;

--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 222
-- Name: detal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detal_id_seq OWNED BY public.detal.id;


--
-- TOC entry 223 (class 1259 OID 19111)
-- Name: dzialanie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dzialanie (
    id integer NOT NULL,
    typ_id smallint NOT NULL,
    opis_dzialania text,
    data_planowana date,
    data_rzeczywista date,
    data_zatwierdzenia date,
    uwagi text
);


ALTER TABLE public.dzialanie OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 19116)
-- Name: dzialanie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dzialanie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dzialanie_id_seq OWNER TO postgres;

--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 224
-- Name: dzialanie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dzialanie_id_seq OWNED BY public.dzialanie.id;


--
-- TOC entry 225 (class 1259 OID 19117)
-- Name: dzialanie_opis_problemu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dzialanie_opis_problemu (
    dzialanie_id integer NOT NULL,
    opis_problemu_id integer NOT NULL
);


ALTER TABLE public.dzialanie_opis_problemu OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 19120)
-- Name: dzialanie_pracownik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dzialanie_pracownik (
    dzialanie_id integer NOT NULL,
    pracownik_id integer NOT NULL
);


ALTER TABLE public.dzialanie_pracownik OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 19123)
-- Name: firma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.firma (
    id integer NOT NULL,
    nazwa character varying(100) NOT NULL,
    kod character varying(20),
    oznaczenie_klienta character varying(50)
);


ALTER TABLE public.firma OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 19126)
-- Name: firma_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.firma_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.firma_id_seq OWNER TO postgres;

--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 228
-- Name: firma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.firma_id_seq OWNED BY public.firma.id;


--
-- TOC entry 229 (class 1259 OID 19127)
-- Name: opis_problemu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opis_problemu (
    id integer NOT NULL,
    opis text,
    przyczyna_bezposrednia text,
    status public.opis_problemu_status_enum DEFAULT 'w trakcie'::public.opis_problemu_status_enum,
    miejsce_zatrzymania public.miejsce_zatrzymania_enum,
    miejsce_powstania public.miejsce_powstania_enum,
    uwagi text,
    kod_przyczyny character varying(50),
    przyczyna_ogolna character varying(150)
);


ALTER TABLE public.opis_problemu OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 19133)
-- Name: opis_problemu_audyt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opis_problemu_audyt (
    opis_problemu_id integer NOT NULL,
    audyt_id integer NOT NULL
);


ALTER TABLE public.opis_problemu_audyt OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 19136)
-- Name: opis_problemu_dzial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opis_problemu_dzial (
    opis_problemu_id integer NOT NULL,
    dzial_id smallint NOT NULL
);


ALTER TABLE public.opis_problemu_dzial OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 19139)
-- Name: opis_problemu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opis_problemu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opis_problemu_id_seq OWNER TO postgres;

--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 232
-- Name: opis_problemu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opis_problemu_id_seq OWNED BY public.opis_problemu.id;


--
-- TOC entry 233 (class 1259 OID 19140)
-- Name: opis_problemu_reklamacja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opis_problemu_reklamacja (
    opis_problemu_id integer NOT NULL,
    reklamacja_id integer NOT NULL
);


ALTER TABLE public.opis_problemu_reklamacja OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 19143)
-- Name: pracownik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pracownik (
    id integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    email character varying(100),
    telefon character varying(20),
    stanowisko character varying(60),
    dzial_id smallint
);


ALTER TABLE public.pracownik OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 19146)
-- Name: pracownik_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pracownik_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pracownik_id_seq OWNER TO postgres;

--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 235
-- Name: pracownik_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pracownik_id_seq OWNED BY public.pracownik.id;


--
-- TOC entry 236 (class 1259 OID 19147)
-- Name: reklamacja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reklamacja (
    id integer NOT NULL,
    firma_id integer NOT NULL,
    typ_id smallint NOT NULL,
    data_otwarcia date,
    data_weryfikacji date,
    "data_zakończenia" date,
    data_produkcji_silownika date,
    nr_reklamacji character varying(100),
    typ_cylindra character varying(150),
    zlecenie character varying(50),
    status boolean DEFAULT false NOT NULL,
    nr_protokolu character varying(100),
    analiza_terminowosci_weryfikacji integer,
    dokument_rozliczeniowy public.dokument_rozliczeniowy_enum,
    nr_dokumentu character varying(100),
    data_dokumentu date,
    nr_magazynu character varying(50),
    nr_listu_przewozowego character varying(100),
    przewoznik character varying(100),
    analiza_terminowosci_realizacji integer
);


ALTER TABLE public.reklamacja OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 19153)
-- Name: reklamacja_detal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reklamacja_detal (
    reklamacja_id integer NOT NULL,
    detal_id integer NOT NULL
);


ALTER TABLE public.reklamacja_detal OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 19156)
-- Name: reklamacja_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reklamacja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reklamacja_id_seq OWNER TO postgres;

--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 238
-- Name: reklamacja_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reklamacja_id_seq OWNED BY public.reklamacja.id;


--
-- TOC entry 239 (class 1259 OID 19157)
-- Name: slownik_dzial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slownik_dzial (
    id smallint NOT NULL,
    nazwa character varying(60) NOT NULL
);


ALTER TABLE public.slownik_dzial OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 19160)
-- Name: slownik_dzial_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slownik_dzial_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slownik_dzial_id_seq OWNER TO postgres;

--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 240
-- Name: slownik_dzial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slownik_dzial_id_seq OWNED BY public.slownik_dzial.id;


--
-- TOC entry 241 (class 1259 OID 19161)
-- Name: slownik_dzialanie_typ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slownik_dzialanie_typ (
    id smallint NOT NULL,
    nazwa character varying(30) NOT NULL
);


ALTER TABLE public.slownik_dzialanie_typ OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 19164)
-- Name: slownik_dzialanie_typ_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slownik_dzialanie_typ_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slownik_dzialanie_typ_id_seq OWNER TO postgres;

--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 242
-- Name: slownik_dzialanie_typ_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slownik_dzialanie_typ_id_seq OWNED BY public.slownik_dzialanie_typ.id;


--
-- TOC entry 243 (class 1259 OID 19165)
-- Name: slownik_sprawdzanie_typ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slownik_sprawdzanie_typ (
    id smallint NOT NULL,
    kod character varying(12) NOT NULL,
    nazwa character varying(40) NOT NULL
);


ALTER TABLE public.slownik_sprawdzanie_typ OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 19168)
-- Name: slownik_sprawdzanie_typ_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slownik_sprawdzanie_typ_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slownik_sprawdzanie_typ_id_seq OWNER TO postgres;

--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 244
-- Name: slownik_sprawdzanie_typ_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slownik_sprawdzanie_typ_id_seq OWNED BY public.slownik_sprawdzanie_typ.id;


--
-- TOC entry 245 (class 1259 OID 19169)
-- Name: slownik_typ_audytu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slownik_typ_audytu (
    id smallint NOT NULL,
    nazwa character varying(15) NOT NULL
);


ALTER TABLE public.slownik_typ_audytu OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 19172)
-- Name: slownik_typ_audytu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slownik_typ_audytu_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slownik_typ_audytu_id_seq OWNER TO postgres;

--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 246
-- Name: slownik_typ_audytu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slownik_typ_audytu_id_seq OWNED BY public.slownik_typ_audytu.id;


--
-- TOC entry 247 (class 1259 OID 19173)
-- Name: slownik_typ_reklamacji; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slownik_typ_reklamacji (
    id smallint NOT NULL,
    nazwa character varying(50) NOT NULL
);


ALTER TABLE public.slownik_typ_reklamacji OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 19176)
-- Name: slownik_typ_reklamacji_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slownik_typ_reklamacji_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slownik_typ_reklamacji_id_seq OWNER TO postgres;

--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 248
-- Name: slownik_typ_reklamacji_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slownik_typ_reklamacji_id_seq OWNED BY public.slownik_typ_reklamacji.id;


--
-- TOC entry 249 (class 1259 OID 19177)
-- Name: sprawdzanie_dzialan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sprawdzanie_dzialan (
    id integer NOT NULL,
    typ_id smallint NOT NULL,
    data date,
    uwagi text,
    status boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sprawdzanie_dzialan OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 19183)
-- Name: sprawdzanie_dzialan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sprawdzanie_dzialan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sprawdzanie_dzialan_id_seq OWNER TO postgres;

--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 250
-- Name: sprawdzanie_dzialan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sprawdzanie_dzialan_id_seq OWNED BY public.sprawdzanie_dzialan.id;


--
-- TOC entry 251 (class 1259 OID 19184)
-- Name: sprawdzanie_dzialan_opis_problemu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sprawdzanie_dzialan_opis_problemu (
    sprawdzanie_dzialan_id integer NOT NULL,
    opis_problemu_id integer NOT NULL
);


ALTER TABLE public.sprawdzanie_dzialan_opis_problemu OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 19187)
-- Name: sprawdzanie_dzialan_pracownik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sprawdzanie_dzialan_pracownik (
    sprawdzanie_dzialan_id integer NOT NULL,
    pracownik_id integer NOT NULL
);


ALTER TABLE public.sprawdzanie_dzialan_pracownik OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 19190)
-- Name: vw_reklamacje_8d; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_reklamacje_8d AS
 SELECT id,
    firma_id,
    typ_id,
    data_otwarcia,
    data_weryfikacji,
    "data_zakończenia",
    data_produkcji_silownika,
    nr_reklamacji,
    typ_cylindra,
    zlecenie,
    status,
    nr_protokolu,
    analiza_terminowosci_weryfikacji,
    dokument_rozliczeniowy,
    nr_dokumentu,
    data_dokumentu,
    nr_magazynu,
    nr_listu_przewozowego,
    przewoznik,
    analiza_terminowosci_realizacji
   FROM public.reklamacja;


ALTER VIEW public.vw_reklamacje_8d OWNER TO postgres;

--
-- TOC entry 4760 (class 2604 OID 19224)
-- Name: audyt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audyt ALTER COLUMN id SET DEFAULT nextval('public.audyt_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 19225)
-- Name: detal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detal ALTER COLUMN id SET DEFAULT nextval('public.detal_id_seq'::regclass);


--
-- TOC entry 4762 (class 2604 OID 19226)
-- Name: dzialanie id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie ALTER COLUMN id SET DEFAULT nextval('public.dzialanie_id_seq'::regclass);


--
-- TOC entry 4763 (class 2604 OID 19227)
-- Name: firma id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.firma ALTER COLUMN id SET DEFAULT nextval('public.firma_id_seq'::regclass);


--
-- TOC entry 4764 (class 2604 OID 19228)
-- Name: opis_problemu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu ALTER COLUMN id SET DEFAULT nextval('public.opis_problemu_id_seq'::regclass);


--
-- TOC entry 4766 (class 2604 OID 19229)
-- Name: pracownik id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownik ALTER COLUMN id SET DEFAULT nextval('public.pracownik_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 19230)
-- Name: reklamacja id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja ALTER COLUMN id SET DEFAULT nextval('public.reklamacja_id_seq'::regclass);


--
-- TOC entry 4769 (class 2604 OID 19231)
-- Name: slownik_dzial id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzial ALTER COLUMN id SET DEFAULT nextval('public.slownik_dzial_id_seq'::regclass);


--
-- TOC entry 4770 (class 2604 OID 19232)
-- Name: slownik_dzialanie_typ id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzialanie_typ ALTER COLUMN id SET DEFAULT nextval('public.slownik_dzialanie_typ_id_seq'::regclass);


--
-- TOC entry 4771 (class 2604 OID 19233)
-- Name: slownik_sprawdzanie_typ id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_sprawdzanie_typ ALTER COLUMN id SET DEFAULT nextval('public.slownik_sprawdzanie_typ_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 19234)
-- Name: slownik_typ_audytu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_audytu ALTER COLUMN id SET DEFAULT nextval('public.slownik_typ_audytu_id_seq'::regclass);


--
-- TOC entry 4773 (class 2604 OID 19235)
-- Name: slownik_typ_reklamacji id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_reklamacji ALTER COLUMN id SET DEFAULT nextval('public.slownik_typ_reklamacji_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 19236)
-- Name: sprawdzanie_dzialan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan ALTER COLUMN id SET DEFAULT nextval('public.sprawdzanie_dzialan_id_seq'::regclass);


--
-- TOC entry 5016 (class 0 OID 19101)
-- Dependencies: 219
-- Data for Name: audyt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audyt (id, firma_id, typ_id, data, zakres, uwagi, termin_wyslania_odpowiedzi, termin_zakonczenia_dzialan) FROM stdin;
42	\N	2	2025-03-04	Struers	Jak radzicie sobie z gospodarką odpadami? Czy macie procedurę gospodarowania odpadami?	2025-04-04	2025-04-30
39	\N	2	2025-03-04	Struers	Czy proces produkcji jest dobrze wdrożony?	2025-04-04	2025-04-30
40	\N	2	2025-03-04	Struers	Jaki jest status obszaru produkcyjnego?	2025-04-04	2025-04-30
41	\N	2	2025-03-04	Struers	W jaki sposób wyjaśniasz i definiujesz wymagania klienta dotyczące produktów, aby móc\nwyprodukować zamówione przedmioty?	2025-04-04	2025-04-30
7	\N	1	2025-03-28	Proces realizacji zakupów	test	\N	\N
9	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
14	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
16	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
6	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
11	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
8	\N	1	2025-03-28	Proces realizacji zakupów	nowy	\N	\N
5	\N	1	2025-03-28	Proces realizacji zakupów	dfsdfsd	\N	\N
13	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
15	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
10	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
12	\N	1	2025-03-28	Proces realizacji zakupów	\N	\N	\N
50	\N	2	2025-02-24	Aebi Schmidt	Czy konserwacja sprzętu i narzędzi produkcyjnych jest kontrolowana?	2025-03-17	2025-04-17
51	\N	2	2025-02-24	Aebi Schmidt	Czy konserwacja sprzętu i narzędzi produkcyjnych jest kontrolowana?	2025-03-17	2025-04-17
52	\N	2	2025-02-24	Aebi Schmidt	Czy niewydane i/lub wadliwe części są odpowiednio zarządzane?	2025-03-17	2025-04-17
53	\N	2	2025-02-24	Aebi Schmidt	Czy niewydane i/lub wadliwe części są odpowiednio zarządzane?	2025-03-17	2025-04-17
54	\N	2	2025-02-24	Aebi Schmidt	Czy specyfikacje zawarte w planie kontroli są kompletne i czy zostały skutecznie wdrożone?	2025-03-17	2025-04-17
55	\N	2	2025-02-24	Aebi Schmidt	Czy specyfikacje zawarte w planie kontroli są kompletne i czy zostały skutecznie wdrożone?	2025-03-17	2025-04-17
56	\N	2	2025-02-24	Aebi Schmidt	Czy specyfikacje zawarte w planie kontroli są kompletne i czy zostały skutecznie wdrożone?	2025-03-17	2025-04-17
57	\N	2	2025-02-24	Aebi Schmidt	Czy niezbędne ilości / wielkości partii produkcyjnych przychodzących materiałów są dostępne w uzgodnionym czasie i we właściwym miejscu składowania / stacji roboczej?	2025-03-17	2025-04-17
58	\N	2	2025-02-24	Aebi Schmidt	Czy niezbędne ilości / wielkości partii produkcyjnych przychodzących materiałów są dostępne w uzgodnionym czasie i we właściwym miejscu składowania / stacji roboczej?	2025-03-17	2025-04-17
43	\N	2	2025-02-24	Aebi Schmidt	Czy w przypadku odchyleń od wymagań jakościowych lub reklamacji przeprowadzane są analizy usterek i skutecznie wdrażane działania naprawcze?	2025-03-17	2025-04-17
44	\N	2	2025-02-24	Aebi Schmidt	Czy ilości/wielkości partii produkcyjnych odpowiadają potrzebom i czy są systematycznie kierowane do kolejnego etapu procesu?	2025-03-17	2025-04-17
45	\N	2	2025-02-24	Aebi Schmidt	Czy procesy i produkty są regularnie audytowane?	2025-03-17	2025-04-17
46	\N	2	2025-02-24	Aebi Schmidt	Czy w przypadku odchyleń od wymagań produktu i procesu analizowane są przyczyny, a działania korygujące sprawdzane pod kątem skuteczności?	2025-03-17	2025-04-17
47	\N	2	2025-02-24	Aebi Schmidt	Czy wyznaczono cele dla procesu produkcyjnego?	2025-03-17	2025-04-17
48	\N	2	2025-02-24	Aebi Schmidt	Czy narzędzia, sprzęt i urządzenia testowe są odpowiednio przechowywane?	2025-03-17	2025-04-17
49	\N	2	2025-02-24	Aebi Schmidt	Czy konserwacja sprzętu i narzędzi produkcyjnych jest kontrolowana?	2025-03-17	2025-04-17
1	\N	1	2025-01-16	Naczelne Kierownictwo	ddd	2025-08-15	\N
3	\N	1	2025-01-16	Naczelne Kierownictwo	\N	\N	\N
2	\N	1	2025-01-16	Naczelne Kierownictwo	\N	\N	\N
72	\N	2	2024-11-22	Claas	Czy przychodzące towary są przechowywane w odpowiedni sposób?	\N	\N
77	\N	2	2024-11-22	Claas	Czy gwarantowana jest uzgodniona jakość produktów i usług zlecanych na zewnątrz?	\N	\N
70	\N	2	2024-11-22	Claas	Czy przeniesienie projektu z fazy rozwojowej do pełnej produkcji zostało zakończone?	\N	\N
73	\N	2	2024-11-22	Claas	\N	\N	\N
63	\N	2	2024-11-22	Claas	Czy wyznaczono cele dla produktu i procesu?	\N	\N
61	\N	2	2024-11-22	Claas	Czy procesy i produkty są regularnie audytowane?	\N	\N
66	\N	2	2024-11-22	Claas	Zdefiniuj listę części zamiennych i min. stan magazynowy w oparciu o jasne kryteria	\N	\N
65	\N	2	2024-11-22	Claas	\N	\N	\N
69	\N	2	2024-11-22	Claas	\N	\N	\N
59	\N	2	2024-11-22	Claas	\N	\N	\N
74	\N	2	2024-11-22	Claas	\N	\N	\N
67	\N	2	2024-11-22	Claas	Czy operatorzy są w stanie wykonywać przydzielone im zadania i czy ich kwalifikacje są aktualizowane?	\N	\N
76	\N	2	2024-11-22	Claas	\N	\N	\N
79	\N	2	2024-11-22	Claas	[Czy wymagania klienta są brane pod uwagę w łańcuchu dostaw?	\N	\N
75	\N	2	2024-11-22	Claas	\N	\N	\N
78	\N	2	2024-11-22	Claas	Czy dostępne są niezbędne zatwierdzenia dla produktów i usług zlecanych na zewnątrz?	\N	\N
64	\N	2	2024-11-22	Claas	\N	\N	\N
68	\N	2	2024-11-22	Claas	Czy istotne cechy są kontrolowane w produkcji?	\N	\N
60	\N	2	2024-11-22	Claas	Czy wymagania klienta są spełnione pod względem produktu i procesu?	\N	\N
80	\N	2	2024-11-22	Claas	Czy dostawcy są wybierani tylko zatwierdzeni i zdolni do zapewnienia jakości?	\N	\N
71	\N	2	2024-11-22	Claas	\N	\N	\N
62	\N	2	2024-11-22	Claas	\N	\N	\N
19	\N	1	2024-10-30	Proces obsługi klienta	\N	\N	\N
18	\N	1	2024-10-30	Proces obsługi klienta	\N	\N	\N
17	\N	1	2024-10-30	Proces obsługi klienta	\N	\N	\N
23	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
31	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
24	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
28	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
30	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
27	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
29	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
26	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
22	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
25	\N	1	2024-09-26	Proces produkcji	\N	\N	\N
20	\N	1	2024-09-25	Proces produkcji	\N	\N	\N
21	\N	1	2024-09-25	Proces produkcji	\N	\N	\N
34	\N	1	2024-06-27	Proces projektowania	\N	\N	\N
35	\N	1	2024-06-26	Proces projektowania	\N	\N	\N
33	\N	1	2024-06-26	Proces projektowania	\N	\N	\N
36	\N	1	2024-06-26	Proces projektowania	\N	\N	\N
32	\N	1	2024-06-26	Proces projektowania	\N	\N	\N
37	\N	1	2024-06-26	Proces projektowania	\N	\N	\N
4	\N	1	2024-06-04	Proces wyrobu	R-375/20226	\N	\N
38	\N	1	2024-04-26	Proces badań i rozwoju	\N	\N	\N
\.


--
-- TOC entry 5018 (class 0 OID 19107)
-- Dependencies: 221
-- Data for Name: detal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detal (id, data_produkcji, kod, nazwa_wyrobu, oznaczenie, ilosc_zlecenie, ilosc_niezgodna, typ, ilosc_uznanych, ilosc_nieuznanych, ilosc_nowych_uznanych, ilosc_nowych_nieuznanych, ilosc_rozliczona, ilosc_nieuznanych_naprawionych) FROM stdin;
90	\N	1172.0	Tłoczysko	CJ2E-80/0.03/80z	16	14	\N	\N	\N	\N	\N	\N	\N
126	\N	20001.0	Korpus ucha	UE25-01w	50	22	\N	\N	\N	\N	\N	\N	\N
216	\N	51197.0	Tuleja prowadząca	Tpu-60/25	180	180	\N	\N	\N	\N	\N	\N	\N
226	\N	665.0	Tłoczysko	CJ-S603-50/2.01A	194	108	\N	\N	\N	\N	\N	\N	\N
251	\N	905997.0	Cylinder tłokowy	CJ-S535-16-40/20/120	10	10	\N	\N	\N	\N	\N	\N	\N
293	\N	70014	\N	174085102	\N	\N	\N	96	0	96	\N	95	\N
294	\N	900444	\N	CN-S34-16-30/490	\N	\N	\N	1	0	1	\N	1	\N
295	\N	900648	\N	CN-S36-20-35/255	\N	\N	\N	18	234	18	234	252	\N
296	\N	900649	\N	CN-S36-20-35/305	\N	\N	\N	6	50	6	50	56	\N
297	\N	900651	\N	CN-S36-20-35/405	\N	\N	\N	10	63	10	63	73	\N
298	\N	900652	\N	CN-S34-20-35/290	\N	\N	\N	0	2	\N	\N	2	\N
299	\N	901125	\N	CN-S85-19-40/1880	\N	\N	\N	0	1	\N	1	1	\N
300	\N	901140	\N	CN-S96-21-40/159	\N	\N	\N	2	0	2	\N	2	\N
301	\N	901143	\N	CN-S98-25-40/50	\N	\N	\N	2	0	2	\N	2	\N
302	\N	901522	\N	CN-S46-20-45/255	\N	\N	\N	20	180	20	180	200	\N
303	\N	902313	\N	CN-S26-24-60/285	\N	\N	\N	1	0	1	\N	\N	\N
304	\N	902519	\N	CN-S18-24-55/253	\N	\N	\N	1	0	1	\N	\N	\N
305	\N	903053	\N	CN-S54-25-63/171	\N	\N	\N	0	1	\N	1	\N	\N
306	\N	903225	\N	CN-S21-25-70/275	\N	\N	\N	1	0	1	\N	1	\N
307	\N	903243	\N	CN-S36-24-70/285	\N	\N	\N	1	0	1	\N	\N	\N
308	\N	903244	\N	CN-S37-31-70/285	\N	\N	\N	0	1	\N	\N	\N	\N
309	\N	903245	\N	CN-S38-32-70/30	\N	\N	\N	1	0	1	\N	\N	\N
310	\N	904949	\N	CT-S380-16-45/4/850+ŁK	\N	\N	\N	1	0	\N	\N	1	\N
311	\N	905030	\N	CJ-S75-25-25/16/55	\N	\N	\N	0	9	\N	\N	9	\N
312	\N	905721	\N	CJ-S12-20-35/20/195  (1206424-0)	\N	\N	\N	1	0	\N	\N	1	\N
313	\N	906203	\N	CJ-S170-16-40/25/152	\N	\N	\N	1	0	\N	\N	1	\N
314	\N	906320	\N	CJ-S163-30-70/40/140	\N	\N	\N	0	1	\N	\N	1	\N
315	\N	906348	\N	CJ-S229-16-70/40/225	\N	\N	\N	1	0	\N	\N	1	\N
316	\N	906349	\N	CJ-S236-20-70/40/320  (1252018-6)	\N	\N	\N	1	0	\N	\N	1	\N
317	\N	906366	\N	CJ-S245-16-70/50/272	\N	\N	\N	1	0	1	\N	1	\N
318	\N	906372	\N	CJ-S265-24-70/50/272	\N	\N	\N	1	0	\N	\N	\N	\N
319	\N	906374	\N	CJ-S268-16-70/36/230	\N	\N	\N	\N	\N	\N	\N	\N	\N
320	\N	906376	\N	CJ-S273-31-70/50/272	\N	\N	\N	1	0	1	\N	\N	\N
321	\N	906839	\N	CJ-S274-30-40/25/90	\N	\N	\N	0	6	\N	\N	6	\N
322	\N	906880	\N	CJ-S389-16-40/20/120  (1180720-8)	\N	\N	\N	1	0	1	\N	1	\N
323	\N	906904	\N	CJ-S14-25-45/30/600x2	\N	\N	\N	0	1	\N	\N	\N	\N
324	\N	906918	\N	CJ-S26-24-45/32/190	\N	\N	\N	0	1	\N	1	\N	\N
325	\N	907398	\N	CJ-S659-16-50/28/500  (355.02.08.00 W)	\N	\N	\N	\N	\N	\N	\N	\N	\N
326	\N	907467	\N	CD-S492-16-50/28/250	\N	\N	\N	1	0	\N	\N	1	\N
327	\N	907524	\N	CD-S739-16-50/28/160	\N	\N	\N	0	1	\N	\N	1	\N
328	\N	907526	\N	CJ-S733-16-50/30/100	\N	\N	\N	\N	\N	\N	\N	\N	\N
329	\N	907538	\N	CJ-S582-16-50/35/300  (711617)	\N	\N	\N	1	0	\N	\N	1	\N
330	\N	907643	\N	CJ-S780-23-50/32/686	\N	\N	\N	1	0	1	\N	1	\N
331	\N	907704	\N	CJ-S21-16-60/40/110	\N	\N	\N	0	2	\N	\N	2	\N
332	\N	907741	\N	CJ-S91-35-60/35/146 P	\N	\N	\N	0	3	\N	\N	3	\N
333	\N	907749	\N	CJ-S120-24-60/40/220	\N	\N	\N	0	1	\N	\N	\N	\N
334	\N	907750	\N	CJ-S122-16-60/36/230	\N	\N	\N	\N	\N	\N	\N	\N	\N
335	\N	907757	\N	CJ-S130-16-60/36/230	\N	\N	\N	\N	\N	\N	\N	\N	\N
336	\N	907758	\N	CJ-S129-5-60/50/3250	\N	\N	\N	1	0	1	\N	1	\N
337	\N	907805	\N	CJ-S724-21-63/36/500 P	\N	\N	\N	\N	\N	\N	\N	\N	\N
338	\N	907825	\N	CJ-S692-16-63/40/40  (1270368-4)	\N	\N	\N	9	0	9	\N	\N	\N
339	\N	907835	\N	CJ-S703-16-63/36/400 (2001.01.11.000) T	\N	\N	\N	\N	\N	\N	\N	\N	\N
340	\N	907872	\N	CJ-S637-25-63/22/81	\N	\N	\N	2	0	2	\N	2	\N
341	\N	907873	\N	CJ-S649-16-63/36/500	\N	\N	\N	\N	\N	\N	\N	\N	\N
342	\N	907884	\N	CJ-S627-16-63/36/500	\N	\N	\N	1	0	1	\N	1	\N
343	\N	907916	\N	CJ-S577-20-63/36/384  (1157075-7)	\N	\N	\N	1	0	1	\N	1	\N
344	\N	907917	\N	CJ-S578-20-63/36/280 (1157077-5)	\N	\N	\N	1	0	1	\N	1	\N
345	\N	908757	\N	CJ-S79-32-90/50/480	\N	\N	\N	1	0	1	\N	1	\N
346	\N	908768	\N	CJ-S136-23-90/63/615	\N	\N	\N	0	3	\N	\N	\N	\N
347	\N	908785	\N	CJ-S32-16-75/28/110	\N	\N	\N	\N	\N	\N	\N	\N	\N
348	\N	908788	\N	CJ-S36-16-75/28/200	\N	\N	\N	\N	\N	\N	\N	\N	\N
349	\N	908791	\N	CJ-S39-16-75/28/110	\N	\N	\N	\N	\N	\N	\N	\N	\N
350	\N	908820	\N	CJ-S137-23-90/63/835	\N	\N	\N	1	0	\N	\N	\N	\N
351	\N	908824	\N	CJ-S145-25-90/45/135	\N	\N	\N	1	0	1	\N	1	\N
352	\N	908825	\N	CJ-S146-21-90/45/433 L	\N	\N	\N	\N	\N	\N	\N	\N	\N
353	\N	908826	\N	CJ-S146-21-90/45/433 P	\N	\N	\N	\N	\N	\N	\N	\N	\N
354	\N	908828	\N	CJ-S151-25-90/50/415	\N	\N	\N	1	0	1	\N	\N	\N
355	\N	909097	\N	CJ-S217-21-100/50/630 L	\N	\N	\N	0	1	\N	\N	\N	\N
356	\N	909187	\N	CJ-S392-23-100/40/552	\N	\N	\N	1	0	\N	\N	\N	\N
357	\N	909194	\N	CJ-S383-21-100/50/250  (GA447)	\N	\N	\N	1	0	1	\N	1	\N
358	\N	909199	\N	CD-S408-16-100/45/270	\N	\N	\N	1	0	1	\N	1	\N
359	\N	909232	\N	CJ-S58-30-110/60/480	\N	\N	\N	1	0	1	\N	1	\N
360	\N	909259	\N	CJ-S116-21-110/50/350	\N	\N	\N	1	0	1	\N	1	\N
361	\N	909316	\N	CJ-S425-20-100/56/500 P	\N	\N	\N	1	0	1	\N	1	\N
362	\N	909318	\N	CJ-S432-31-100/40/685	\N	\N	\N	6	0	6	\N	\N	\N
363	\N	909331	\N	CJ-S121-21-110/50/500	\N	\N	\N	1	0	1	\N	1	\N
364	\N	909337	\N	CJ-S131-21-110/50/350	\N	\N	\N	0	9	\N	9	9	\N
365	\N	909338	\N	CJ-S132-31-110/55/920	\N	\N	\N	5	0	5	\N	\N	\N
366	\N	909407	\N	CJ-S17-21-120/70/560 	\N	\N	\N	1	0	1	\N	1	\N
367	\N	909410	\N	CJ-S23-21-120/60/200	\N	\N	\N	1	0	\N	\N	1	\N
368	\N	909902	\N	CJ-S624-16-80/36/800 (0928.02.02.000 W) T	\N	\N	\N	\N	\N	\N	\N	\N	\N
369	\N	909903	\N	CJ-S625-7-80/45/800  (347.03.09.00 W) T	\N	\N	\N	\N	\N	\N	\N	\N	\N
370	\N	909926	\N	CJ-S701-21-80/40/500	\N	\N	\N	1	0	1	\N	1	\N
371	\N	909932	\N	CJ-S628-7-80/45/800  (0942.02.01.000 W) T	\N	\N	\N	\N	\N	\N	\N	\N	\N
372	\N	909948	\N	CJ-S694-21-80/40/500 L	\N	\N	\N	\N	\N	\N	\N	\N	\N
373	\N	909949	\N	CJ-S694-21-80/40/500 P	\N	\N	\N	\N	\N	\N	\N	\N	\N
374	\N	909953	\N	CJ-S696-16-80/28/110	\N	\N	\N	\N	\N	\N	\N	\N	\N
375	\N	909974	\N	CJ-S682-20-80/45/80	\N	\N	\N	\N	\N	\N	\N	\N	\N
376	\N	914937	\N	CT-S344-40/3/542 bez ZAW.i ŁK.	\N	\N	\N	2	0	2	\N	2	\N
377	\N	914960	\N	CT-S376-16-75/4/1500+ZCT+ŁK	\N	\N	\N	1	0	\N	\N	1	\N
378	\N	924943	\N	CT-S376-16-75/4/1700+ŁK	\N	\N	\N	0	1	\N	\N	1	\N
379	\N	926073	\N	CJ-S01-18-40/22/143	\N	\N	\N	1	0	1	\N	1	\N
380	\N	974306	\N	CJ2E-50/28/500z UE2-50w	\N	\N	\N	1	0	\N	\N	1	\N
381	\N	974311	\N	CJ2E-50/28/250z UE2-50w	\N	\N	\N	1	0	\N	\N	1	\N
382	\N	994658	\N	CJ-S143-20-90/36/900 ( 2115.01.05.000)	\N	\N	\N	0	1	\N	\N	\N	\N
383	\N	994854	\N	CJ-S772-20-80/40/265	\N	\N	\N	2	0	2	\N	2	\N
11	\N	906378.0	\N	 CJ-S279-20-70/40/320	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	\N	909097.0	\N	CJ-S217-21-100/50/630	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	\N	902517.0	\N	CN-S17-21-55/100	\N	\N	\N	\N	\N	\N	\N	\N	\N
283	\N	955055.0	Cylinder tłokowy	CJ2E-100/56/800z	40	4	\N	\N	\N	\N	\N	\N	\N
155	\N	26069.0	Nurnik	CN-S32-32/0.01	205	55	\N	\N	\N	\N	\N	\N	\N
220	\N	51393.0	Tuleja prowadząca	CJ-S623-80/0.02	30	30	\N	\N	\N	\N	\N	\N	\N
272	\N	909215.0	Cylinder tłokowy	CD-S44-32-110/90/415	10	10	\N	\N	\N	\N	\N	\N	\N
41	\N	909724.0	\N	CD-S77-21-140/63/100	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	\N	909408.0	\N	CD-S16-21-120/60/100	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	\N	909258.0	\N	CJ-S114-21-110/45/300	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	\N	909410.0	\N	CJ-S23-21-120/60/200	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	\N	906343.0	\N	CJ-S217-70/40/580	\N	\N	\N	\N	\N	\N	\N	\N	\N
167	\N	31016.0	Płyta	CJ-S90-110/2.04	113	113	\N	\N	\N	\N	\N	\N	\N
20	\N	907758.0	\N	CJ-S129-5-60/50/3250 	\N	\N	\N	\N	\N	\N	\N	\N	\N
234	\N	725.0	Tłoczysko	CJ-S724-50/0.03	555	555	\N	\N	\N	\N	\N	\N	\N
200	\N	450.0	Tłoczysko	CJ-S627-50/2.01	40	40	\N	\N	\N	\N	\N	\N	\N
84	\N	110633.0	Obudowa cylindra	CN-S35-35/1.00/305	102	102	\N	\N	\N	\N	\N	\N	\N
281	\N	909790.0	Cylinder tłokowy	CJ-S585-16-80/45/80	100	90	\N	\N	\N	\N	\N	\N	\N
140	\N	208421.0	Obudowa cylindra	CJ-S735-80/1.00	40	40	\N	\N	\N	\N	\N	\N	\N
19	\N	909407.0	\N	CJ-S17-21-120/70/560	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	\N	909337.0	\N	CJ-S131-21-110/50/350	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	\N	909331.0	\N	CJ-S121-21-110/50/500	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	\N	907916.0	\N	CJ-S577-20-63/36/384	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	\N	900648.0	\N	CN-S36-20-35/255	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	\N	900649.0	Cylinder nurnikowy	CN-S36-20-35/305	100	70	\N	\N	\N	\N	\N	\N	\N
32	\N	900651.0	\N	CN-S36-20-35/405	\N	\N	\N	\N	\N	\N	\N	\N	\N
280	\N	909723.0	Cylinder tłokowy	CJ-S76-8-140/80/1250	4	4	\N	\N	\N	\N	\N	\N	\N
253	\N	906320.0	Cylinder tłokowy	CJ-S163-30-70/40/140	75	40	\N	\N	\N	\N	\N	\N	\N
97	\N	12053.0	Tuleja cylindra 	CJ-S39-75/1.01-1	101	101	\N	\N	\N	\N	\N	\N	\N
169	\N	3228.0	Tuleja cylindra	CJ-S544-50/1.01-2	20	1	\N	\N	\N	\N	\N	\N	\N
260	\N	907537.0	Cylinder tłokowy	CJ-S686-23-50/32/510	100	60	\N	\N	\N	\N	\N	\N	\N
209	\N	47502.0	Denko	CJ-S129-60/1.02	104	34	\N	\N	\N	\N	\N	\N	\N
269	\N	907917.0	Cylinder tłokowy	CJ-S578-20-63/36/280	30	30	\N	\N	\N	\N	\N	\N	\N
185	\N	37320.0	Tłok	CJ-S392-100/0.15	180	21	\N	\N	\N	\N	\N	\N	\N
137	\N	208018.0	Obudowa cylindra	CJ2K-63/1.00/320D	103	70	\N	\N	\N	\N	\N	\N	\N
144	\N	208580.0	Obudowa cylindra	CJ2K-80/1.00/160D	30	30	\N	\N	\N	\N	\N	\N	\N
261	\N	907550.0	Cylinder tłokowy	CJ-S458-16-40/20/120	10	10	\N	\N	\N	\N	\N	\N	\N
191	\N	40777.0	Tłok	CJ-S43-60/0.15	30	3	\N	\N	\N	\N	\N	\N	\N
131	\N	203610.0	Obudowa cylindra	CJ-S10-85/1.00	54	5	\N	\N	\N	\N	\N	\N	\N
21	\N	99747.0	\N	3/8" 02C 40	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	\N	906880.0	Cylinder tłokowy	CJ-S389-16-40/20/120	10	10	\N	\N	\N	\N	\N	\N	\N
110	\N	1400.0	Tłoczysko	CJ-S129-60/2.01/3250 DCr	41	41	\N	\N	\N	\N	\N	\N	\N
125	\N	193109.0	Korpus	CN-S10-85/1.02	50	54	\N	\N	\N	\N	\N	\N	\N
39	\N	909672.0	\N	CJ-S265-24-70/50/272	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	\N	907744.0	\N	CJ-S114-24-60/36/200	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	\N	906376.0	\N	CJ-S273-31-70/50/272	\N	\N	\N	\N	\N	\N	\N	\N	\N
24	\N	909349.0	\N	CJ-S12-20-35/20/195	\N	\N	\N	\N	\N	\N	\N	\N	\N
243	\N	902312.0	Cylinder nurnikowy	CN-S25-60/195	100	33	\N	\N	\N	\N	\N	\N	\N
16	\N	909194.0	\N	CJ-S383-21-100/50/250	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	\N	909926.0	\N	CJ-S701-21-80/40/500	\N	\N	\N	\N	\N	\N	\N	\N	\N
165	\N	302506.0	Obudowa cylindra	CN-S17-55/1.00	135	135	\N	\N	\N	\N	\N	\N	\N
164	\N	29774.0	Tłoczysko	CJ-S21-60/0.03	205	120	\N	\N	\N	\N	\N	\N	\N
4	\N	903611.0	\N	CN-S10-25-85/285	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	\N	900652.0	\N	 CN-S34-20-35/290	\N	\N	\N	\N	\N	\N	\N	\N	\N
91	\N	118067.0	Obudowa cylindra	CJ-S578-63/1.00	41	17	\N	\N	\N	\N	\N	\N	\N
88	\N	1145.0	Tłoczysko	CJ2E-80/0.03/200z	15	6	\N	\N	\N	\N	\N	\N	\N
186	\N	3773.0	Tuleja cylindra	CJ-S130-60/1.01-1	16	16	\N	\N	\N	\N	\N	\N	\N
102	\N	1278.0	Tłoczysko	CJ-S694-80/0.03	206	37	\N	\N	\N	\N	\N	\N	\N
72	\N	108669.0	Tłoczysko	CD-S742-80/2.00/190	18	18	\N	\N	\N	\N	\N	\N	\N
42	\N	902520.0	\N	CN-S19-24-55/253	\N	\N	\N	\N	\N	\N	\N	\N	\N
63	\N	10568.0	Korpus	CJ-S274-40/1.02-1	107	85	\N	\N	\N	\N	\N	\N	\N
96	\N	118615.0	Obudowa cylindra	CD-742-80/1.00/190	17	17	\N	\N	\N	\N	\N	\N	\N
73	\N	108670.0	Tłoczysko	CD-S742-80/2.00/280	18	18	\N	\N	\N	\N	\N	\N	\N
25	\N	902519.0	\N	CN-S18-24-5/253	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	\N	903244.0	\N	CN-S37-31-70/285	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	\N	906918.0	\N	CJ-S26-24-45/32/190	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	\N	907749.0	\N	CJ-S120-24-60/40/220	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	\N	903245.0	\N	CN-S38-32-70/30	\N	\N	\N	\N	\N	\N	\N	\N	\N
239	\N	901125.0	Cylinder nurnikowy	CN-S85-40/1880	50	15	\N	\N	\N	\N	\N	\N	\N
278	\N	909322.0	Cylinder tłokowy	CJ-S434-20-100/70/914	25	17	\N	\N	\N	\N	\N	\N	\N
249	\N	905100.0	Cylinder teleskopowy	CT-S95-28/720	40	20	\N	\N	\N	\N	\N	\N	\N
159	\N	26607.0	Nurnik	CT-S363-30/2.01	22	22	\N	\N	\N	\N	\N	\N	\N
143	\N	208517.0	Obudowa cylindra	CJ2K-80/630z	20	20	\N	\N	\N	\N	\N	\N	\N
259	\N	907318.0	Cylinder tłokowy	CJ-S712-63/380	50	25	\N	\N	\N	\N	\N	\N	\N
132	\N	206222.0	Obudowa cylindra	CJ-S430-40/1.00	33	1	\N	\N	\N	\N	\N	\N	\N
128	\N	201513.0	Obudowa cylindra	CN-S45-45/1.00	200	70	\N	\N	\N	\N	\N	\N	\N
266	\N	907836.0	Cylinder tłokowy	CJ-S643-63/280	20	20	\N	\N	\N	\N	\N	\N	\N
76	\N	109245.0	Tłoczysko	CJ-S114-110/2.00	11	11	\N	\N	\N	\N	\N	\N	\N
157	\N	26350.0	Nurnik	CT-S246-75/0.05/1700	106	30	\N	\N	\N	\N	\N	\N	\N
83	\N	110523.0	Obudowa cylindra	CN-S32-32/2.00	306	100	\N	\N	\N	\N	\N	\N	\N
138	\N	208383.0	Obudowa cylindra	CJ-S170-70/1.00	200	200	\N	\N	\N	\N	\N	\N	\N
274	\N	909247.0	Cylinder tłokowy	CJ-S99-110/120	30	30	\N	\N	\N	\N	\N	\N	\N
127	\N	200406.0	Obudowa cylindra	CN-S34-30/1.00	400	200	\N	\N	\N	\N	\N	\N	\N
233	\N	70925.0	Obejma	CJ-S101-110/1.03	45	15	\N	\N	\N	\N	\N	\N	\N
189	\N	40489.0	Nurnik	R-581/2009/0.01	55	55	\N	\N	\N	\N	\N	\N	\N
263	\N	907641.0	Cylinder tłokowy	CD-S776-20-50/28/100	45	45	\N	\N	\N	\N	\N	\N	\N
242	\N	902056.0	Cylinder nurnikowy	CN-S80-50/550 A	20	8	\N	\N	\N	\N	\N	\N	\N
10	\N	901520.0	\N	CN-S45-24-45/170	\N	\N	\N	\N	\N	\N	\N	\N	\N
217	\N	51292.0	Tuleja prowadząca	CJ-S701-80/0.02	560	40	\N	\N	\N	\N	\N	\N	\N
146	\N	209060.0	Obudowa cylindra	CJ2E-100/100/800	12	8	\N	\N	\N	\N	\N	\N	\N
212	\N	50116.0	Tuleja prowadząca	CN-S66-40/0.02	14	14	\N	\N	\N	\N	\N	\N	\N
279	\N	909333.0	Cylinder tłokowy	CJ-S123-110/300-100	32	20	\N	\N	\N	\N	\N	\N	\N
151	\N	210004.0	Nurnik 	R-896/2022/175	55	55	\N	\N	\N	\N	\N	\N	\N
277	\N	909319.0	Cylinder tłokowy	CJ-S394-16-100/60/30	20	12	\N	\N	\N	\N	\N	\N	\N
92	\N	118101.0	Obudowa cylindra	CJ-S637-63/1.00	152	75	\N	\N	\N	\N	\N	\N	\N
235	\N	783.0	Tłoczysko	CJ2E-63/0.03/320z	45	6	\N	\N	\N	\N	\N	\N	\N
271	\N	909187.0	Cylinder tłokowy	CJ-S392-23-100/40/552	220	52	\N	\N	\N	\N	\N	\N	\N
71	\N	108069.0	Tłoczysko	CJ-S637-63/2.00	162	93	\N	\N	\N	\N	\N	\N	\N
282	\N	934.0	Tłoczysko	CJ-S637-63/2.01	150	15	\N	\N	\N	\N	\N	\N	\N
254	\N	906348.0	Cylinder tłokowy	CJ-S229-70/225	50	50	\N	\N	\N	\N	\N	\N	\N
87	\N	113515.0	Obudowa cylindra	CN-S11-85/1.00	30	30	\N	\N	\N	\N	\N	\N	\N
252	\N	906211.0	Cylinder tłokowy	CJ-S268-40/60	28	8	\N	\N	\N	\N	\N	\N	\N
208	\N	47500.0	Korpus	CJ-S282-70/1.02	65	65	\N	\N	\N	\N	\N	\N	\N
248	\N	905030.0	Cylinder tłokowy	CJ-S75-25/55	200	5	\N	\N	\N	\N	\N	\N	\N
116	\N	15651.0	Koncówka tłoczyska	CJ-S136-90/2.02-1	385	35	\N	\N	\N	\N	\N	\N	\N
237	\N	900445.0	Cylinder nurnikowy	CN-S36-30/100	200	4	\N	\N	\N	\N	\N	\N	\N
196	\N	4377.0	Rura nurnika	CN-S36-70/2.01 DCr	270	270	\N	\N	\N	\N	\N	\N	\N
57	\N	103616.0	Nurnik	CJ-S11-85/2.00	152	40	\N	\N	\N	\N	\N	\N	\N
120	\N	165107.0	Obudowa cylindra	CN-S19-55/1.00	100	100	\N	\N	\N	\N	\N	\N	\N
199	\N	44377.0	Nurnik	CN-S36-70/2.00	24	7	\N	\N	\N	\N	\N	\N	\N
70	\N	107728.0	Tłoczysko 	CJ-S627-63/2.00	200	8	\N	\N	\N	\N	\N	\N	\N
95	\N	118585.0	Obudowa cylindra	CJ-S670-80/1.00/80	40	40	\N	\N	\N	\N	\N	\N	\N
34	\N	903243.0	Cylinder nurnikowy	CN-S36-70/285	80	6	\N	\N	\N	\N	\N	\N	\N
273	\N	909232.0	Cylinder tłokowy	CJ-S58-30-110/60/480	90	90	\N	\N	\N	\N	\N	\N	\N
162	\N	26700.0	Nurnik	CN-S26-60/2.01	245	9	\N	\N	\N	\N	\N	\N	\N
285	\N	976.0	Tłoczysko	CJ-S114-60/0.03DCr	165	100	\N	\N	\N	\N	\N	\N	\N
163	\N	279501.0	Denko z uchem	CT-S166-60/3.00	70	43	\N	\N	\N	\N	\N	\N	\N
188	\N	40370.0	Nurnik	R-500/2008/1.01	53	13	\N	\N	\N	\N	\N	\N	\N
172	\N	34042.0	Nurnik 	CN-S38-70/0.03	102	6	\N	\N	\N	\N	\N	\N	\N
179	\N	36642.0	Nurnik fi 45	CT-S396-32/0.02	51	28	\N	\N	\N	\N	\N	\N	\N
161	\N	26642.0	Nurnik 45	CT-S396-32/0.02	29	8	\N	\N	\N	\N	\N	\N	\N
101	\N	1263.0	Tłoczysko	CJ-S701-21-80	200	200	\N	\N	\N	\N	\N	\N	\N
267	\N	907872.0	Cylinder tłokowy	CJ-S637-25-63/22/81	150	5	\N	\N	\N	\N	\N	\N	\N
18	\N	906349.0	Cylinder tłokowy	CJ-S236-20-70/40/320	100	19	\N	\N	\N	\N	\N	\N	\N
215	\N	51183.0	Tuleja prowadząca	CJ-S170-70/0.02	410	50	\N	\N	\N	\N	\N	\N	\N
219	\N	51384.0	Tuleja prowadząca	CJ-S760-80/0.02	11	11	\N	\N	\N	\N	\N	\N	\N
203	\N	47285.0	Korpus	CJ-S585-80/1.02	13	13	\N	\N	\N	\N	\N	\N	\N
124	\N	17362.0	Końcówka nurnika	CN-S10-85/2.02	165	65	\N	\N	\N	\N	\N	\N	\N
262	\N	907575.0	Obudowa	CJ-S503-16-40/20/350	50	3	\N	\N	\N	\N	\N	\N	\N
250	\N	905996.0	Cylinder tłokowy	CJ-S534-15-40/25/1000	120	2	\N	\N	\N	\N	\N	\N	\N
136	\N	207933.0	Obudowa	CJ-S712-63/1.00	50	50	\N	\N	\N	\N	\N	\N	\N
156	\N	26170.0	Nurnik	CN-S45-45/0.03	200	7	\N	\N	\N	\N	\N	\N	\N
265	\N	907820.0	Cylinder tłokowy	CJ-S710-16-63/36/420	50	50	\N	\N	\N	\N	\N	\N	\N
183	\N	37253.0	Tłok	CJ-S90-110/0.10	32	14	\N	\N	\N	\N	\N	\N	\N
133	\N	206230.0	Obudowa cylindra	CJ-S529-40/1.00	101	11	\N	\N	\N	\N	\N	\N	\N
28	\N	902313.0	Obudowa cylindra	CN-S26-24-60/285	51	6	\N	\N	\N	\N	\N	\N	\N
118	\N	1595.0	Tłoczysko	CJ-S118-110/2.01	60	8	\N	\N	\N	\N	\N	\N	\N
65	\N	106071.0	Tłoczysko	CJ-S458-40/2.00	35	35	\N	\N	\N	\N	\N	\N	\N
257	\N	906839.0	Cylinder tłokowy	CJ-S274-40/90	151	34	\N	\N	\N	\N	\N	\N	\N
152	\N	21696.0	Przyłącze	CN-S08-85/1.03	150	6	\N	\N	\N	\N	\N	\N	\N
153	\N	235.0	Tłoczysko	CJ-S274-40/0.03.	205	19	\N	\N	\N	\N	\N	\N	\N
224	\N	62445.0	Pierścień	ŁK-S02-36/0.02	65	55	\N	\N	\N	\N	\N	\N	\N
122	\N	169940.0	Tłoczysko kompletne	R- 864/2017	160	16	\N	\N	\N	\N	\N	\N	\N
121	\N	169908.0	Tłoczysko kompletne	R-375/2006	45	15	\N	\N	\N	\N	\N	\N	\N
195	\N	42152.0	Tuleja cylindra 	CN-S36-70/1.01	240	240	\N	\N	\N	\N	\N	\N	\N
218	\N	51341.0	Tuleja prowadząca	CJ-S114-60/0.02	150	150	\N	\N	\N	\N	\N	\N	\N
130	\N	203231.0	Obudowa cylindra	CJ-S36-70/1.00	250	130	\N	\N	\N	\N	\N	\N	\N
98	\N	121505.0	Tuleja cylindra 	CN-S16-45/1.01	41	41	\N	\N	\N	\N	\N	\N	\N
77	\N	109246.0	Tłoczysko	CJ-S116-110/2.00	20	14	\N	\N	\N	\N	\N	\N	\N
168	\N	31020.0	Płyta	CJ-S116-110/2.01	122	122	\N	\N	\N	\N	\N	\N	\N
81	\N	109404.0	Tłoczysko z uchem	CJ-S23-120/2.00	121	3	\N	\N	\N	\N	\N	\N	\N
86	\N	113021.0	Obudowa cylindra	CN-S54-63/1.000	150	27	\N	\N	\N	\N	\N	\N	\N
108	\N	1328.0	Tłoczysko	CJ-S463-80/0.03/800	13	8	\N	\N	\N	\N	\N	\N	\N
175	\N	34380.0	Rura nurnika	CN-S54-63/2.01	150	23	\N	\N	\N	\N	\N	\N	\N
240	\N	901143.0	Cylinder nurnikowy	CN-S98-25-40/50	50	50	\N	\N	\N	\N	\N	\N	\N
109	\N	137020.0	Ucho	2010593.01	10	9	\N	\N	\N	\N	\N	\N	\N
171	\N	34040.0	Nurnik	CN-S19-55/0.03 DCr	114	15	\N	\N	\N	\N	\N	\N	\N
64	\N	106061.0	Tłoczysko	CJ-S389-40/2.00	22	22	\N	\N	\N	\N	\N	\N	\N
52	\N	100249.0	Korpus	CJ-S573-63/1.02	26	26	\N	\N	\N	\N	\N	\N	\N
223	\N	54600.0	Tulejka 	CN-S19-70/2.04	200	200	\N	\N	\N	\N	\N	\N	\N
174	\N	34377.0	Rura nurnika	CN-S36-70/2.01	140	20	\N	\N	\N	\N	\N	\N	\N
115	\N	15584.0	Ucho	CN-S95-50/1.02-2	30	30	\N	\N	\N	\N	\N	\N	\N
62	\N	1056.0	Tłoczysko	CJ-S245-70/0.03	38	38	\N	\N	\N	\N	\N	\N	\N
145	\N	208792.0	Obudowa cylindra	CJ-S137-90/1.00	460	6	\N	\N	\N	\N	\N	\N	\N
264	\N	907649.0	Cylinder tłokowy	CJ-S785-50/200	100	100	\N	\N	\N	\N	\N	\N	\N
38	\N	903053.0	Cylinder nurnikowy	CN-S54-53/171	150	150	\N	\N	\N	\N	\N	\N	\N
55	\N	103613.0	Cylinder nurnikowy	CN-S10-85/2.00	100	17	\N	\N	\N	\N	\N	\N	\N
170	\N	34022.0	Nurnik	CN-S17-55/0.03	103	46	\N	\N	\N	\N	\N	\N	\N
173	\N	34044.0	Nurnik	CN-S98-40/0.03	55	55	\N	\N	\N	\N	\N	\N	\N
206	\N	47487.0	Denko	CN-S98-40/0.07	55	55	\N	\N	\N	\N	\N	\N	\N
113	\N	1547.0	Tłoczysko	CJ-S392-100/2.01	64	6	\N	\N	\N	\N	\N	\N	\N
123	\N	17306.0	Końcówka nurnika	CN-S19-60/2.02	60	260	\N	\N	\N	\N	\N	\N	\N
149	\N	209244.0	Obudowa cylindra	CJ-S115-110/1.00	46	7	\N	\N	\N	\N	\N	\N	\N
111	\N	144410.0	Łożysko kuliste	ŁK-S02-36/0.00	50	50	\N	\N	\N	\N	\N	\N	\N
56	\N	103615.0	Nurnik	CN-S14-90/2.00	30	30	\N	\N	\N	\N	\N	\N	\N
89	\N	115100.0	Obudowa cylindra	CT-S95-28/1.00	60	7	\N	\N	\N	\N	\N	\N	\N
148	\N	209241.0	Obudowa cylindra	CJ-S116-110/1.00	100	100	\N	\N	\N	\N	\N	\N	\N
99	\N	1231.0	Tłoczysko	CJ-S580-80/2.01 DCr	21	21	\N	\N	\N	\N	\N	\N	\N
270	\N	907957.0	Cylinder tłokowy	CJ-S499-63/2.00	50	50	\N	\N	\N	\N	\N	\N	\N
37	\N	909259.0	Cylinder tłokowy	CJ-S116-110/350	100	1	\N	\N	\N	\N	\N	\N	\N
194	\N	41343.0	Tuleja cylindra	CN-S54-63/1.01	155	155	\N	\N	\N	\N	\N	\N	\N
158	\N	26511.0	Nurnik 40	CT-S95-28/0.02	66	66	\N	\N	\N	\N	\N	\N	\N
93	\N	118546.0	Obudowa cylindra	CJ-S556-80/1.00/250	55	55	\N	\N	\N	\N	\N	\N	\N
245	\N	902509.0	Cylinder nurnikowy	CN-S09-55/200A	100	5	\N	\N	\N	\N	\N	\N	\N
107	\N	129927.0	Tuleja cylindra	CJ-S58-110/1.01	120	120	\N	\N	\N	\N	\N	\N	\N
58	\N	10368.0	Denko	CN-S34-30/1.02-1	201	201	\N	\N	\N	\N	\N	\N	\N
176	\N	347.0	Tłoczysko	CJ-S389-40/2.01	45	45	\N	\N	\N	\N	\N	\N	\N
69	\N	1075.0	Tłoczysko	CJ-S277-70/0.03	44	44	\N	\N	\N	\N	\N	\N	\N
180	\N	3710.0	Tuleja cylindra	CJ-S594-63/1.01/615	12	8	\N	\N	\N	\N	\N	\N	\N
142	\N	208440.0	Obudowa cylindra	CJ-S701-80/1.00	205	205	\N	\N	\N	\N	\N	\N	\N
284	\N	970026.0	Zestaw hydrauliczny	R-739/2013/585L	35	45	\N	\N	\N	\N	\N	\N	\N
268	\N	907910.0	Cylinder tłokowy	CJ-S594-63/585	35	18	\N	\N	\N	\N	\N	\N	\N
117	\N	15741.0	Korpus ucha	CJ-S115-110/3.01	43	5	\N	\N	\N	\N	\N	\N	\N
147	\N	209086.0	Obudowa cylindra	CJ-S392-100/1.00	320	320	\N	\N	\N	\N	\N	\N	\N
222	\N	52923.0	Wkładka łożyska	CJ-S152-125/0.08	55	55	\N	\N	\N	\N	\N	\N	\N
82	\N	109716.0	Tłoczysko	CJ-S70-140/2.00	21	3	\N	\N	\N	\N	\N	\N	\N
221	\N	52854.0	Tuleja wahliwa	CJ-S448-80/0.04	24	24	\N	\N	\N	\N	\N	\N	\N
207	\N	47492.0	Korpus	CJ-S701-80/1.02	241	241	\N	\N	\N	\N	\N	\N	\N
236	\N	900071.0	Cylinder nurnikowy	CN-S82-25/157	100	100	\N	\N	\N	\N	\N	\N	\N
181	\N	37210.0	Tłok	CJ-S499-63/0.15	60	60	\N	\N	\N	\N	\N	\N	\N
106	\N	129855.0	Końcówka tłoczyska z rurką	CJ-S136-90/2.02-2	315	125	\N	\N	\N	\N	\N	\N	\N
201	\N	46064.0	Tlok	CJ-S594-63/0.15	80	80	\N	\N	\N	\N	\N	\N	\N
198	\N	44251.0	Tuleja cylindra	R-898/2023	220	120	\N	\N	\N	\N	\N	\N	\N
23	\N	906372.0	Cylinder tłokowy	CJ-S265-24-70/50/272	250	9	\N	\N	\N	\N	\N	\N	\N
53	\N	102310.0	Nurnik	CN-S26-60/2.00	250	110	\N	\N	\N	\N	\N	\N	\N
225	\N	64441.0	Podstawa	ŁK-S09-55/0.01	120	120	\N	\N	\N	\N	\N	\N	\N
204	\N	47483.0	Korpus	CN-S105-40/1.02	28	28	\N	\N	\N	\N	\N	\N	\N
205	\N	47484.0	Korpus	CJ-S43-55/1.02	30	30	\N	\N	\N	\N	\N	\N	\N
160	\N	26628.0	Nurnik 90	CT-S224-60/0.05	56	56	\N	\N	\N	\N	\N	\N	\N
78	\N	109247.0	Tłoczysko z uchem	CJ-S118-110/2.00	85	15	\N	\N	\N	\N	\N	\N	\N
85	\N	111089.0	Obudowa 	CN-S96-40/1.00	44	4	\N	\N	\N	\N	\N	\N	\N
276	\N	909263.0	Cylinder tłokowy	CJ-S118-110/1220	78	3	\N	\N	\N	\N	\N	\N	\N
79	\N	109252.0	Tłoczysko z uchem	CJ-S131-110/2.00	20	20	\N	\N	\N	\N	\N	\N	\N
150	\N	209246.0	Obudowa	CJ-S118-110/1.00	78	2	\N	\N	\N	\N	\N	\N	\N
119	\N	165104.0	Przyłącze	CN-S19-60/2.03	946	8	\N	\N	\N	\N	\N	\N	\N
103	\N	129135.0	Obudowa cylindra	CJ-S428-100/1.00	56	30	\N	\N	\N	\N	\N	\N	\N
67	\N	107118.0	Tłoczysko	CJ-S603-50/2.00 A	102	1	\N	\N	\N	\N	\N	\N	\N
229	\N	70014.0	Tłoczysko	174085102	220	220	\N	\N	\N	\N	\N	\N	\N
54	\N	103207.0	Nurnik	CN-S36-70/2.00	130	130	\N	\N	\N	\N	\N	\N	\N
228	\N	70003.0	Tłoczysko	84150605503	60	60	\N	\N	\N	\N	\N	\N	\N
141	\N	208434.0	Obudowa cylindra	CJ-S692-80/1.00	207	207	\N	\N	\N	\N	\N	\N	\N
105	\N	129410.0	Obudowa cylindra	CJ-S32-120/1.00	12	12	\N	\N	\N	\N	\N	\N	\N
227	\N	675.0	Tłoczysko	CJ-S709-50/0.003	52	52	\N	\N	\N	\N	\N	\N	\N
104	\N	129409.0	Obudowa cylindra	CJ-S31-120/1.00	14	14	\N	\N	\N	\N	\N	\N	\N
214	\N	50781.0	Tuleja prowadząca	CJ-S58-110/0.02	100	91	\N	\N	\N	\N	\N	\N	\N
230	\N	70019.0	Tłoczysko	84150610202	130	48	\N	\N	\N	\N	\N	\N	\N
135	\N	207356.0	Obudowa cylindra	CJ-S784-50/1.00	55	55	\N	\N	\N	\N	\N	\N	\N
139	\N	208394.0	Obudowa	CJ-S245-70/1.00	50	6	\N	\N	\N	\N	\N	\N	\N
66	\N	107106.0	Tłoczysko	CJ-S641-50/200	106	106	\N	\N	\N	\N	\N	\N	\N
184	\N	37316.0	Tłok	CJ-S136-90/0.15	530	216	\N	\N	\N	\N	\N	\N	\N
134	\N	207331.0	Obudowa cylindra	CJ-S711-50/1.00	106	14	\N	\N	\N	\N	\N	\N	\N
193	\N	40948.0	Tłok	CJ-S58-110/0.15	85	82	\N	\N	\N	\N	\N	\N	\N
112	\N	15408.0	Ucho	CJ-S84-60/2.02	95	95	\N	\N	\N	\N	\N	\N	\N
202	\N	46552.0	Tuleja dystansowa	CJ-S116-32/0.08	110	105	\N	\N	\N	\N	\N	\N	\N
231	\N	70029.0	Tłoczysko 52R522	174084103	200	8	\N	\N	\N	\N	\N	\N	\N
94	\N	118564.0	Obudowa cylindra	CJ-S578-80/1.00	41	41	\N	\N	\N	\N	\N	\N	\N
166	\N	309213.0	Obudowa cylindra	CJ-S58-110/1.00	100	100	\N	\N	\N	\N	\N	\N	\N
178	\N	35622.0	Tłoczysko	CJ8C-40/25/0.03/250z	210	34	\N	\N	\N	\N	\N	\N	\N
197	\N	4388.0	Tuleja cylindra	CJ-S118-110/1.01-2	81	81	\N	\N	\N	\N	\N	\N	\N
211	\N	50113.0	Tuleja prowadząca	CN-S51-40/0.02	42	42	\N	\N	\N	\N	\N	\N	\N
241	\N	901521.0	Cylinder nurnikowy	CN-S44-45/253	423	80	\N	\N	\N	\N	\N	\N	\N
114	\N	1552.0	Tłoczysko	CJ-S58-110/2.01	80	80	\N	\N	\N	\N	\N	\N	\N
177	\N	34969.0	Rura tłoczyska	CJ-S136-90/2.01-2	180	92	\N	\N	\N	\N	\N	\N	\N
213	\N	50640.0	Tuleja prowadząca	CJ-S05-45/0.02	235	235	\N	\N	\N	\N	\N	\N	\N
210	\N	50058.0	Tuleja prowadząca	CN-S32-32/0.02	200	3	\N	\N	\N	\N	\N	\N	\N
187	\N	3875.0	Tuleja cylindra	CJ-S268-70/1.01-1	51	51	\N	\N	\N	\N	\N	\N	\N
100	\N	126026.0	Tuleja cylindra	CJ8G-40/1.01/250	260	22	\N	\N	\N	\N	\N	\N	\N
232	\N	70030.0	Tłoczysko	35R522	240	138	\N	\N	\N	\N	\N	\N	\N
129	\N	202507.0	Obudowa cylindra	CN-S17-55/1.00-1	125	125	\N	\N	\N	\N	\N	\N	\N
80	\N	109255.0	Tłoczysko 	CJ-S123-110/2.00	46	29	\N	\N	\N	\N	\N	\N	\N
192	\N	40811.0	Tłok	CJ-S172-63/0.15	260	18	\N	\N	\N	\N	\N	\N	\N
182	\N	37211.0	Tłok	CJ-S24-75/0.15	102	102	\N	\N	\N	\N	\N	\N	\N
59	\N	103904.0	Nurnik	CT-S363-30/2.00	20	20	\N	\N	\N	\N	\N	\N	\N
190	\N	40773.0	Tłok	CJ-S13-60/0.15	191	191	\N	\N	\N	\N	\N	\N	\N
60	\N	10407.0	Denko	CT-375-60/1.02	100	100	\N	\N	\N	\N	\N	\N	\N
75	\N	109065.0	Tłoczysko z uchem	CJ-S136-90/2.00	160	37	\N	\N	\N	\N	\N	\N	\N
61	\N	10530.0	Denko	CT-123-50/0.05	100	100	\N	\N	\N	\N	\N	\N	\N
68	\N	107138.0	Tłoczysko 	CJ-S592-50/2.00	10	1	\N	\N	\N	\N	\N	\N	\N
154	\N	258019.0	Tłoczysko kompletne	CJ-S136-90/2.00	277	11	\N	\N	\N	\N	\N	\N	\N
74	\N	109063.0	Tłoczysko	CJ-S136-90/2.01	100	20	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5020 (class 0 OID 19111)
-- Dependencies: 223
-- Data for Name: dzialanie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dzialanie (id, typ_id, opis_dzialania, data_planowana, data_rzeczywista, data_zatwierdzenia, uwagi) FROM stdin;
1	2	Aktualizacja instrukcji I-TBR-01 oraz dostosowanie jej do obecnego i aktualnego sposobu realizacji projektów	2024-05-20	2024-05-19	\N	\N
2	2	Aktualizacja instrukcji technologicznych.	2024-12-30	\N	\N	\N
3	2	Synchronizacja dokumentacji technologicznej i projektowej oraz przegląd pod kątem zgodności.	2024-12-31	\N	\N	\N
4	2	Przygotowanie instrukcji dotyczącej zarządzania zmianami w dokumentacji technologicznej.	2024-09-15	2024-09-15	\N	\N
5	2	Przygotowanie instrukcji dotyczącej zarządzania zmianami w dokumentacji technologicznej.	2024-09-15	2024-09-15	\N	\N
6	2	Opracowanie checklisty podpisów (zainteresowanych Działów) zatwierdzających wykonanie nowego wyrobu i wprowadzanie wyrobu do planu produkcji.	2024-08-30	2024-09-30	\N	\N
7	2	Wprowadzenie zmian do instrukcji	2024-12-30	\N	\N	\N
8	2	Wyniki realizacji celów jakościowych zostały zaktualizowane.	2024-10-10	2024-10-07	\N	\N
9	2	W chwili nieobecności odpowiedzialnego mistrza za wystawienie karty zostali zobowiązani do tej czynności brygadziści wydziału. Problem dotyczył galwanizerni.	2024-10-10	2024-10-07	\N	\N
10	2	Przekazywanie informacji zwrotnej z Działu Planowania Produkcji do Działu Kontroli Jakości. Kontrola Jakości zoobowiązuje się do przekazywania kompletnych informacji.	\N	\N	\N	Status: praca ciągła
11	2	Uczulenie i kontrola pracownikow krajalni odnośnie zasadności i konieczności wykonywania każdorazowych zapisów	2024-09-30	2024-09-30	\N	\N
12	2	W chwili nieobecności odpowiedzialnego mistrza za wystawienie karty zostali zobowiązani do tej czynności brygadziści wydziału. Problem dotyczył galwanizerni.	2024-09-30	2024-09-30	\N	\N
13	2	Wdrożono doraźnie trzecią zmianę na malarni w celu udrożnienia przepływu detali przez ten wydział. Zmiana trzecia będzie utrzymana do momentu zaniknięcia wąskiego gardła.	2024-09-30	2024-09-30	\N	\N
14	2	Opracowanie harmonogramu przeglądów i wymiany narzędzi oraz bieżące uzupełnianie listy sprzętu wymagającego serwisu lub wymiany.	2024-12-15	\N	\N	Status: praca ciągła w trakcie realizacji
15	2	Karty zostały wycofane z obiegu, nie zaktualizowano instrukcji	2024-09-27	2024-09-27	\N	\N
16	2	Aktualizacja harmonogramu i kolejkowania w programie produkcyjnym detali z wymaganą kartą kontrolną do wglądu dla kontrolerów i mistrzów produkcji.	2024-09-27	2024-09-27	\N	\N
17	2	Detale prototypowe aktualnie są realizowane na produkcji razem z detalami regularnie produkowanymih. W związku z powyższym detale prototypowe są zlecane dla odpowiednich mistrzów RĘCZNIE a planowane są na codziennych naradach planistycznych.	2024-09-27	2024-09-27	\N	\N
18	2	Sterowanie ręczne na naradach produkcyjnych i przydział osób nadzorujących oraz maszyn.	2024-09-27	2024-09-27	\N	\N
19	2	Sterowanie ręczne na naradach produkcyjnych i przydział osób nadzorujących oraz maszyn.	2024-09-27	2024-09-27	\N	\N
20	2	Wyniki realizacji celów jakościowych zostały zaktualizowane.	2024-11-04	2024-11-04	\N	\N
21	2	Wdrożono elektroniczną ścieżkę obiegu dotyczącą zapytań ofertowych, wdrażania nowych projektów w sytemie streamsoft DSM. Kierownicy działów HSM, TL, TTK, PP oraz NJ dodają dane odpowienich obszarów i je akcepują	2024-10-30	2024-10-30	\N	\N
22	2	Wdrożono elektroniczną ścieżkę obiegu dotyczącą zapytań ofertowych, wdrażania nowych projektów w sytemie streamsoft DSM. Kierownicy działów HSM, TL, TTK, PP oraz NJ dodają dane odpowienich obszarów i je akcepują	2024-10-30	2024-10-30	\N	\N
23	2	Kontrola detali przed wysyłką.	2024-06-20	\N	\N	\N
24	2	Usunięto niezidentyfikowane detale	2025-02-25	2025-02-25	\N	\N
25	2	Usunięto niezidentyfikowane detale	2025-02-25	2025-02-25	\N	\N
26	2	Sprecyzownie w instrukcji miejsca docelowego, w którym należy sprawdzać wyniki malowania	2025-04-15	\N	\N	\N
27	2	Dokumentacja starych części jest systematycznie wprowadzana	2025-03-17	2025-03-17	\N	\N
28	2	Staramy się przeprowadzać kontrole każdego dnia, czasami kilkukrotnie.	\N	\N	\N	\N
29	2	Wyznaczono dodatkowe godziny pracy w celu wyprowadzenia wszystkich zaległości.\n\n	2025-03-30	\N	\N	\N
30	2	Dochodzenie wewnętrznych części NOK odbyło się niezwłocznie po zakończeniu audytu.	2025-03-25	2025-03-25	\N	\N
31	2	Szkolenie przypominające wytypowanych pracowników na temat konieczności dokonywania regularnych przeglądów podległych maszyn	2025-04-11	\N	\N	\N
32	2	Przeprowadzenie dodatkowych prac porządkowych.	\N	\N	\N	\N
33	2	Szkolenie w sprawie niezgodności jakościowych oraz wskaźników produkcyjnych.	2025-03-18	2025-03-18	\N	\N
34	2	Szkolenie w sprawie niezgodności jakościowych oraz wskaźników produkcyjnych.	2025-03-18	2025-03-18	\N	\N
35	2	Szkolenie w sprawie niezgodności jakościowych oraz wskaźników produkcyjnych.	2025-03-18	2025-03-18	\N	\N
36	2	Zmiana sposobu analizy wyników niezgodności oraz prezentacji działań korygujących	\N	\N	\N	Status: praca ciągła
37	2	Wykonać nowe identyfikatory odpadów , oraz umieszczeniue ich w widocznych miejscach	\N	\N	\N	\N
38	2	Wyroby zostały spakowane i przekazane na magazyn wyrobów gotowych	2025-04-04	2025-04-04	\N	\N
39	2	Chemikalia powinny być przechowywane w przeznaczonych do tego celu magazynach. Zostały uaktualnione, zgodnie z najnowszymi przepisami, wszystkie karty charakterystyk substancji chemicznych używanych w zakładzie. Dodatkowo pozyskano od dostawcy farb w sprayu aktualną kartę charakterystyki (chemia bez identyfikacji).\nZakup wanien ociekowych pod beczki z chemikaliami	\N	\N	\N	Status: praca ciągła
40	2	W chwili obecnej trwa remont malarni oraz docolowa zmiana organizacji tego wydziału. Planowany termin zakończenia remontu 30.04.2025. Planowana jest jednocześnie budowa zadaszenia zewnętrznego przed malarnią w celu zabezpieczenia cylindrów przed warunkami atmosferycznymi.	\N	\N	\N	\N
41	1	1. Przegląd i aktualizacja wszytskich instrukcji dotyczących TBR.\n2. Systematyczne przeglądy instrukcji i procedur dotyczących TBR i ich aktualizacja minimum raz w roku.	\N	\N	\N	Status: praca ciagła
42	1	1. Przegląd i aktualizacja wszytskich instrukcji dotyczących TTK.\n2. Systematyczne przeglądy instrukcji i procedur dotyczących TTK i ich aktualizacja minimum raz w roku.	2025-02-28	\N	\N	\N
43	1	1. Ujednolicenie sposobu opracowywania nowej dokumentacji.\n2. Przegląd i aktualizacja dokumentacji, która wraca do produkcji po dłuższej przerwie	\N	\N	\N	\N
44	1	1. Przygotowanie instrukcji dotyczącej zarządzania zmianami w dokumentacji technologicznej.	2024-09-15	2024-09-15	\N	\N
45	1	2.  Wprowadzenie rejestru zmian w formie elektronicznej	2024-07-30	2024-07-20	\N	\N
46	1	Bierzące wypełnianie dokumentów dotyczących zlecenia wykonania nowego wyrobu. Kontrola audytorów podczas audytów wewnętrznych.	\N	\N	\N	\N
47	1	1. Przegląd i aktualizacja wszytskich instrukcji dotyczących TTK.\n2. Systematyczne przeglądy instrukcji i procedur dotyczących TTK i ich aktualizacja minimum raz w roku.	\N	\N	\N	\N
48	1	Bieżące, comiesięczne, raportowanie o wykonaniu celów jakościowych przez Kierownika Produkcji. Regularne spotkania podsumowujące z kierownikami działów oraz audyt wewnętrzny w zakresie raportowania i realizacji celów jakościowych.	\N	\N	\N	\N
49	1	Aktualizacja instrukcji o rozszeżenie uprawnień brygadzisty w chwili nieobecności mistrza produkcji.	2025-01-31	\N	\N	\N
50	1	Wprowadzenie regularnych spotkań między Działem Produkcji a Działem Jakości w celu omówienia działań naprawczych i ich rezultatów.	\N	\N	\N	Status: praca ciągła
51	1	Systematyczne kontrole wewnętrzne potwierdzające uzupełnienie przewodników.	\N	\N	\N	\N
52	1	Aktualizacja instrukcji o rozszeżenie uprawnień brygadzisty w chwili nieobecności mistrza produkcji.	2025-01-31	\N	\N	\N
53	1	Bierząca analiza wąskich gardeł na malarni i zwiększanie mocy produkcyjnych . Opracowanie i wdrożenie zasad 5S  w procesie malarni oraz aktualizacja instrukcji obsługi. Wykonanie remontu malarni.	2025-01-31	\N	\N	\N
54	1	systematycznie tworzenie listy i wspraca PP i TTK	2024-12-30	\N	\N	\N
55	1	1. Przegląd i aktualizacja wszytskich instrukcji dotyczących PP.\n2. Systematyczne przeglądy instrukcji i procedur dotyczących PP i ich aktualizacja minimum raz w roku.	2024-12-30	\N	\N	\N
56	1	Aktualizacja na bierząco	\N	\N	\N	Status: praca ciągła
57	1	Nadanie kodów w programie produkcji na każdy detal prototypowy.	\N	\N	\N	\N
58	1	Należy w programie producyjnym nadać kody dla każdej częsci składowej danego wyrobu prototypowego co w znacznej mierze ułatwi śledzenie każdej części oraz pozwoli na dokładne przypisanie mistrza nadzorującego. Taki sam sposób jak w produkcji regularnej.	\N	\N	\N	\N
59	1	Stworzenie instrukcji dotyczącej postępowania z prototypami.	2025-01-05	\N	\N	\N
60	1	Bieżące, comiesięczne, raportowanie o wykonaniu celów jakościowych przez Kierownika Produkcji. Regularne spotkania podsumowujące z kierownikami działów oraz audyt wewnętrzny w zakresie raportowania i realizacji celów jakościowych.	\N	\N	\N	\N
61	1	Przegląd i dostosowanie Instrukcji I-HSM-I do nowo wprowadzonych procedur zatwierdzanych przez osoby odpowiedzialne za dany obszar.	2024-12-31	\N	\N	\N
62	1	Przegląd i dostosowanie Instrukcji I-HSM-I do nowo wprowadzonych procedur zatwierdzanych przez osoby odpowiedzialne za dany obszar.	2024-12-31	\N	\N	\N
63	1	Usunięcie operacji/naprawa prasy hydraulicznej/odpowiednie oprzyrządowanie/przestawienie prasy	2025-03-31	\N	\N	\N
64	1	W niektórych wymaganiach temperatura niższa niż 50 stopni. Jesteśmy w trakcie wyjaśniania. Prośba o zakup osuszacza.	\N	\N	\N	\N
65	1	spotkanie z pracownikami, ustalono, że mają porządkować 1-1,5h dziennie. Planowany koniec do konca września. Jeszcze nie. Do kiedy?	\N	\N	\N	\N
66	1	Opracowany szablon listy kontrolnej. Wykorzystaliśmy do tego program do obsługi obiegu dokumentów DMS. Nasz informatyk stworzył moduł dla zapytań ofertowych wprowadzając ścieżkę zatwierdzeń, gdzie zapytanie ofertowe przechodzi przez poszczególne działy, które zatwierdzają (lub nie) do dalszej pracy nad nim. Na razie w fazie projektu.\nCo dalej?	\N	\N	\N	\N
67	1	W toku --> robione - spotkania z pracownikami, wtedy odbywa się analiza danych, wyciąganie wniosków. Spotkania połączone ze spotkaniami w sprawie FMEA. TERMIN nast. spotkania: SRODA 10:00, POZNIEJ CO 2 TYGODNIE. \n\n* Dodatkowy komentarz: przeprowadzaj SPC w sposób systematyczny, aby udoskonalić procesy\n?????????????	\N	\N	\N	\N
68	1	Wszystkie detale prototypowe, na każdym etapie produkcji, będą składowane są w paletach z nadstawką w kolorze szarym	\N	\N	\N	Status: praca ciągła
69	1	Wszystkie detale prototypowe na każdym etapie produkcji składowane są w paletach z nadstawką w kolorze szarym	\N	\N	\N	Status: praca ciągła
70	1	Sprecyzowanie instrukcji, przeszkolenie pracowników, nadzór Mistrza.	2025-04-15	\N	\N	\N
71	1	Systematyczne wprowadzanie, kontrola Kierownika Technologiczno-konstrukcyjnego	\N	\N	\N	\N
72	1	Sprawdzanie wykonania badań przez Kierownika Jakości	\N	\N	\N	\N
73	1	Wprowadzono weryfikację na bierząco w trakcie toku produkcyjnego.\n\nOd teraz detale reklamacyjne będą poddawane kontroli jedynie w miejscu do tego przeznaczonym (serwisie) 	\N	\N	\N	\N
74	1	Co tygodniowa analiza statusu niezgodności	\N	\N	\N	Status: praca ciągła
75	1	Systematyczny nadzór nad dokonywaniem przeglądów codziennych pracowników produkcji	\N	\N	\N	\N
76	1	Wyznaczenie osoby odpowiedzialnej za dokonanie porządków na zewnątrz zakładu. Zmobilizowanie Mistrzów Produkcji do kontroli czystości miejsc pracy. Regularne kontrole Mistrzow oraz Kierowników, dotyczące ładu i porządku na terenie zakładu.	\N	\N	\N	\N
77	1	Bierzące raportowanie do Zarządu (min raz w miesiącu) o stopniu realizac ji działań korygujących i doskonalających oraz stanie zaległości.	\N	\N	\N	Status: praca ciągła
78	1	Bierzące raportowanie do Zarządu (min raz w miesiącu) o stopniu realizac ji działań korygujących i doskonalających oraz stanie zaległości.	\N	\N	\N	Status: praca ciągła
79	1	Bierzące raportowanie do Zarządu (min raz w miesiącu) o stopniu realizac ji działań korygujących i doskonalających oraz stanie zaległości.	\N	\N	\N	Status: praca ciągła
80	1	Głębsza analiza danych i włącznie w proces dodatkowych osób	\N	\N	\N	Status: praca ciągła
81	1	W razie absencji pracowników odpowiedzailnych za pakowanie, przesuwać pracowników z innych działów, żeby wyroby nie zalegały na malarnii a były pakowane na bieżoąco i zdawane na magazyn wyrobów gotowych. Zatwierdzanie dyspozycje po fizycznym dostarczeniu spakowanych wyrobów na magazyn wyrobów gotowych.Palety zgłoszone do odbioru przez przewoźnika ustawiać w miejscu odbioru P1(nie trzymac na regale)	\N	\N	\N	Status: praca ciągła
82	1	Bieżąca analiza zgodności otrzymywanych od dostawców  karty charakterystyk z aktualnie obowiązującymi przepisami	\N	\N	\N	Status: praca ciągła
83	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
84	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
85	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
86	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
87	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
88	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
89	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
90	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
91	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
92	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
93	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
94	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
95	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
96	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
97	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
98	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
99	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
100	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
101	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
102	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
103	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
104	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
105	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
106	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
107	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
108	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
109	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
110	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
111	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów. 	2024-12-10	\N	\N	Status: praca ciągła
112	2	Sprawdzenie tłoczysk na produkcji po procesie spawania.	\N	\N	\N	Status: praca ciągła
113	2	Przeszkolenie pracowników w zakresie prawidłowego postepowania z wadliwymi produktami. Większe zaangażowanie Mistrzów Montażu w proces prób siłowników. (Ewentualne stworzenie szczegółowej instrukcji postępowania z brakami).	2025-01-31	2025-01-14	\N	\N
114	2	Przeszkolenie pracowników w zakresie prawidłowego postepowania z wadliwymi produktami. Większe zaangażowanie Mistrzów Montażu w proces prób siłowników. (Ewentualne stworzenie szczegółowej instrukcji postępowania z brakami).	2025-01-31	2025-01-14	\N	\N
115	2	Wysłanie brakujących tulei slizgowych do Odbiorcy	2024-11-30	2024-11-29	\N	\N
116	2	Wysłanie brakujących tulei slizgowych do Odbiorcy	2024-11-30	2024-11-29	\N	\N
117	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
118	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
119	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
120	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
121	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
122	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
123	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
124	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
125	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
126	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
127	2	Brak siłowników do sprawdzenia na stanie.	2025-01-07	2025-01-07	\N	\N
128	2	Brak siłowników do sprawdzenia na stanie.	2025-01-08	2025-01-08	\N	\N
129	2	Brak siłowników do sprawdzenia na stanie.	2025-01-08	2025-01-08	\N	\N
130	2	Brak siłowników do sprawdzenia na stanie.	2025-01-09	2025-01-09	\N	\N
131	2	Brak siłowników do sprawdzenia na stanie.	2025-01-09	2025-01-09	\N	\N
132	2	Sprawdzono w produkcji- 250 cylindrów.	2025-01-13	2025-01-13	\N	\N
133	2	Sprawdzono w magazynie- 43 cylindry.	2025-01-13	2025-01-13	\N	\N
134	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów.	2025-01-13	2025-01-13	\N	\N
135	2	Przeglądanie siłowników po montażu pierściania oporowego w celu wykrycia wiórów.	2025-01-13	2025-01-13	\N	\N
136	2	Brak siłowników do sprawdzenia na stanie.	2025-01-13	2025-01-13	\N	\N
137	2	Brak siłowników do sprawdzenia na stanie.	2025-01-13	2025-01-13	\N	\N
138	2	Brak siłowników do sprawdzenia na stanie.	2025-01-13	2025-01-13	\N	\N
139	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
140	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
141	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
142	2	Obróbka i kalibrowanie gwintów	\N	\N	\N	Status: praca ciągła
143	2	Sprawdzono 32 sztuki w magazynie.	2025-01-14	2025-01-14	\N	\N
144	2	Sprawdzono 32 sztuki w magazynie.	2025-01-14	2025-01-14	\N	\N
145	2	Brak siłowników do sprawdzenia na stanie.	2025-01-14	2025-01-14	\N	\N
146	2	Dłuższe czasy próby siłowników.	2025-01-24	2025-01-14	\N	\N
147	2	Dłuższe czasy próby siłowników.	2025-01-24	2025-01-14	\N	\N
148	2	Dłuższe czasy próby siłowników.	2025-01-24	2025-01-14	\N	\N
149	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
150	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
151	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
152	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
153	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
154	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
155	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
156	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
157	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
158	2	Nadzór i pisemne wyjaśnienie sytuacji braku detekcji na próbach.	2025-01-24	2025-01-14	\N	\N
159	2	Ustawienie nowego zaworu i wysyłka do klienta	2025-01-17	2025-01-14	\N	\N
160	2	Ustawienie nowego zaworu i wysyłka do klienta	2025-01-17	2025-01-14	\N	\N
161	2	Sprawdzenie stanów magazynowych (brak uszkodzeń smarowniczki). Rozmowa z pracownikami malarni na temat pakowania siłowników.	2025-02-07	2025-02-07	\N	\N
162	2	Szkolenie pracowników montażu i nadzór nad ich pracą.	\N	2025-02-07	\N	\N
163	2	Szkolenie pracowników montażu i nadzór nad ich pracą.	\N	2025-02-07	\N	\N
164	2	Szkolenie pracowników montażu i nadzór nad ich pracą.	\N	2025-02-07	\N	\N
165	2	Sprawdzono wykonanie detali na produkcji	2025-01-04	2025-02-07	\N	\N
166	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2026-03-03	\N	\N
167	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2026-03-03	\N	\N
168	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
169	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
170	2	Zapoznanie pracowników malarni i magazynu z reklamacją.	2025-03-07	2025-03-03	\N	\N
171	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
172	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
173	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
174	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
175	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
176	2	Brak siłowników do sprawdzenia na stanie.	2025-03-03	2025-03-03	\N	\N
177	2	Wymiana uszczelnienia i ustalenie przyczyny przecieku (uszczelnienei uszkodzone podczas montażu- po wymianie szczelny)	2025-03-07	2025-03-07	\N	\N
178	2	Przeprowadzenie twstów z innym rodzajem uszczelnień (wynik pozytywny na możliwość montazu z innymi rodzajami uszczelnień)	2025-03-07	2025-03-07	\N	\N
179	2	Wymiana uszczelnienia i ustalenie przyczyny przecieku (uszczelnienei uszkodzone podczas montażu- po wymianie szczelny)	2025-03-07	2025-03-07	\N	\N
180	2	Przeprowadzenie twstów z innym rodzajem uszczelnień (wynik pozytywny na możliwość montazu z innymi rodzajami uszczelnień)	2025-03-07	2025-03-07	\N	\N
181	2	 Kontrola procesu nakładania pasty montażowej przy najbliższym montażu.	2025-03-21	2025-03-21	\N	\N
182	2	 Kontrola siłowników z magazynu na rampie otrzymanej od Assa Abloy.	2025-03-06	2025-03-06	\N	\N
183	2	Szukanie uch o właściwych parametrach w celu uniknięcia wtłaczania tulei redukcyjnych oraz ponownego zaciskania łożysk u uchach z zakupu.	2025-04-18	2025-03-06	\N	\N
184	2	Szukanie uch o właściwych parametrach w celu uniknięcia wtłaczania tulei redukcyjnych oraz ponownego zaciskania łożysk u uchach z zakupu.	2025-04-18	2025-03-06	\N	\N
185	2	Wyjaśnienie przyczyn niedomówień i wysłanie nowego rysunku ofertowego do akceptacji.	2025-04-11	2025-04-11	\N	\N
186	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
187	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
188	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
189	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
190	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
191	2	Brak siłowników do sprawdzenia na stanie.	2025-04-14	2025-04-14	\N	\N
192	2	 Sprawdzenie obróbki ślusarskiej pod względem obróbki spoin. ( Proces obróbki prawidłowy. Pracownicy zapoznani z zasadami. Na stanowisku obecne instrukcje obrazkowe jak powinna wyglądać spoina po obróbce.)	2025-04-14	2025-04-14	\N	\N
193	2	 Sprawdzenie procesu spawania. (Spawanie wg WPS. Używane zaślepki na króćce)	2025-04-14	2025-04-14	\N	\N
194	2	 Sprawdzenie wykonania tłoków na linii produkcyjnej. ( Proces wykonania tłoków i tulei prowadzącej jest najbardziej stabilnym procesem z zakładzie. Wykonanie gwintów prawidłowe.)	2025-04-14	2025-04-14	\N	\N
195	2	 Sprawdzenie procesu montażu. (Kleje do gwintów przechowywane prawidłowo. Prawidłowo oznakowane w oryginalnym opakowaniu. Zachowanie czasów schnięcia. Tłoki dokręcane kluczem dynamometrycznym.)	2025-04-14	2025-04-14	\N	\N
196	2	 Sprawdzenie dokumentacji technicznej. ( Na dokumentacji technicznej oznaczony i opisany sposób montażu tłoka. Podane momenty dokręcenia tłoka.)	2025-04-14	2025-04-14	\N	\N
197	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	\N	\N	\N
198	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	\N	\N	\N
199	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	\N	\N	\N
200	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	\N	\N	\N
201	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	\N	\N	\N
202	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
203	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
204	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
205	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
206	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
207	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
208	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
209	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
210	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
211	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
212	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
213	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
214	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
215	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
216	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
217	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
218	1	Zmiana konstrukcyjna (przecięty pierścień podporowy w celu łatwego montażu?). 	2024-12-20	\N	\N	Status: praca ciągła
219	1	Zmiana konstrukcyjna (przecięty pierścień podporowy w celu łatwego montażu?). 	2024-12-20	\N	\N	Status: praca ciągła
220	1	Zmiana konstrukcyjna (zaokrąglenie krawędzi w zamku uszczelnienia głównego?)	2024-12-20	\N	\N	Status: praca ciągła
221	1	Zmiana konstrukcyjna (zaokrąglenie krawędzi w zamku uszczelnienia głównego?)	2024-12-20	\N	\N	Status: praca ciągła
222	1	Zmiana konstrukcyjna (wydłużenie kanałka pod uszczelkę?). 	2024-12-20	\N	\N	Status: praca ciągła
223	1	Zmiana konstrukcyjna (wydłużenie kanałka pod uszczelkę?). 	2024-12-20	\N	\N	Status: praca ciągła
224	1	Wyrywkowa kontrola podczas montażu.	\N	\N	\N	Status: praca ciągła
225	1	Wyrywkowa kontrola podczas montażu.	\N	\N	\N	Status: praca ciągła
226	1	Stworzenie przyrządu spawalniczego uniemożliwiającego nieprawidłowy montaż detali	2025-01-31	\N	\N	Status: praca ciągła
227	1	Modernizacja stanowiska prób siłowników przez automatyzację programu testowego oraz zapisywanie wyników badań.	2025-12-31	\N	\N	Status: praca ciągła
228	1	Modernizacja stanowiska prób siłowników przez automatyzację programu testowego oraz zapisywanie wyników badań.	2025-12-31	\N	\N	Status: praca ciągła
229	1	Modernizacja stanowisk prób, na których monitorowany będzie wymiar mocowań siłowników	2025-12-31	\N	\N	Status: praca ciągła
230	1	W przypadku zmiany kolejności wykonywanych operacji na Montażu, wymagana pełna kontrola zlecenia przez Mistrza	\N	\N	\N	Status: praca ciągła
231	1	W przypadku zmiany kolejności wykonywanych operacji na Montażu, wymagana pełna kontrola zlecenia przez Mistrza	\N	\N	\N	Status: praca ciągła
326	2	Odcięcie i ponowne przyspawanie korpusów. 	\N	\N	\N	\N
327	2	Ponowna obróbka	\N	\N	\N	\N
232	1	Modernizacja stanowiska prób siłowników przez automatyzację programu testowego oraz zapisywanie wyników badań.	2025-12-31	\N	\N	Status: praca ciągła
233	1	Modernizacja stanowiska prób siłowników przez automatyzację programu testowego oraz zapisywanie wyników badań.	2025-12-31	\N	\N	Status: praca ciągła
234	1	Przeszkolenie pracowników w zakresie prawidłowego postepowania z wadliwymi produktami. 	2025-01-31	2025-01-14	\N	\N
235	1	Przeszkolenie pracowników w zakresie prawidłowego postepowania z wadliwymi produktami. 	2025-01-31	2025-01-14	\N	\N
236	1	Większe zaangażowanie Mistrzów Montażu w proces prób siłowników. (Ewentualne stworzenie szczegółowej instrukcji postępowania z brakami).	2025-01-31	\N	\N	Status: praca ciągła\n14-01-2025
237	1	Większe zaangażowanie Mistrzów Montażu w proces prób siłowników. (Ewentualne stworzenie szczegółowej instrukcji postępowania z brakami).	2025-01-31	\N	\N	Status: praca ciągła\n14-01-2025
238	1	Zmiana technologiczna- nowy sposób toczenia  gwintów	2024-06-06	2024-06-06	\N	\N
239	1	Zmodernizowana myjka 	2023-12-22	2023-12-22	\N	\N
240	1	Odmuchiwanie części po każdym etapie obróbki	2024-02-24	\N	\N	Status: praca ciągła\n13-01-2025
241	1	Modernizacja stanowiska prób	2025-12-31	\N	\N	Status: praca ciągła\n13-01-2025
242	1	Weryfikacja, poprawa i uaktualnienie procedury postępowania z siłownikami po wykryciu przecieku, podczas prób.	2025-01-17	\N	\N	\N
243	1	Modernizacja stanowiska prób	2025-12-31	\N	\N	\N
244	1	Przeszkolenie pracowników i uczulenie Mistrzów w zakresie prawidłowego stanu narzędzi oraz zwracanie uwagi na wykonanie detali zgodnie z rysunkim.	2025-01-31	2025-01-13	\N	\N
245	1	Wzmożona kontrola wszystkich detali.	\N	\N	\N	Status: praca ciągła
246	1	Zmiana konstrukcyjna (przecięty pierścień podporowy w celu łatwego montażu?). 	2025-12-31	\N	\N	Status: praca ciągła
247	1	Zmiana konstrukcyjna (zaokrąglenie krawędzi w zamku uszczelnienia głównego?)	2025-12-31	\N	\N	Status: praca ciągła
248	1	Zmiana konstrukcyjna (wydłużenie kanałka pod uszczelkę?). 	2025-12-31	\N	\N	Status: praca ciągła
249	1	Wyrywkowa kontrola podczas montażu.	\N	\N	\N	Status: praca ciągła
250	1	Modernizacja stanowiska prób siłowników przez automatyzację programu testowego oraz zapisywanie wyników badań.	2025-12-31	\N	\N	Status: praca ciągła
251	1	Przeszkolenie pracowników w zakresie prawidłowego postepowania z wadliwymi produktami. 	2025-01-07	2025-01-14	\N	\N
252	1	Większe zaangażowanie Mistrzów Montażu w proces prób siłowników. (Ewentualne stworzenie szczegółowej instrukcji postępowania z brakami).	2025-01-31	\N	\N	Status: praca ciągła\n14-01-2025
253	1	Wprowadzenie osłon na każdym etapie spawania	2024-07-12	2024-07-12	\N	\N
254	1	Kontrolowanie spawaczy pod względem używania osłon 	\N	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
255	1	Ochrona elementów spawanych w paletach przed odpryskami 	2024-07-12	\N	\N	Status: praca ciągła\nSzkolenie  13-01-2025
256	1	Wyrywkowa kontrola części składowych przed montażem 	\N	\N	\N	Status: praca ciągła
257	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	\N	\N	Status: praca ciągła
258	1	Szkolenie pracowników pracujących przy stanowiskach prób. 	2025-01-31	2025-01-13	\N	\N
259	1	Szkolenie pracowników ze skutków nieuważnego montażu.	2025-01-31	2025-01-13	\N	\N
260	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
261	1	Szkolenia pracowników i mistrzów z zakresu WTO oraz odpowiedzialności i obowiązków.	2025-01-24	2025-01-13	\N	\N
262	1	Nadzór i weryfikacja skuteczności zarządzania montażem.	\N	2025-01-13	\N	\N
263	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
264	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
265	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
266	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
267	1	Szkolenia pracowników i mistrzów z zakresu WTO oraz odpowiedzialności i obowiązków.	2025-01-24	2025-01-13	\N	\N
268	1	Szkolenia pracowników i mistrzów z zakresu WTO oraz odpowiedzialności i obowiązków.	2025-01-24	2025-01-13	\N	\N
269	1	Szkolenia pracowników i mistrzów z zakresu WTO oraz odpowiedzialności i obowiązków.	2025-01-24	2025-01-13	\N	\N
270	1	Wprowadzenie rejestru zmian kolejności lub/i rodzaju operacji w procesach technologicznych.	2025-01-31	2025-01-13	\N	\N
271	1	Wprowadzenie rejestru zmian kolejności lub/i rodzaju operacji w procesach technologicznych.	2025-01-31	2025-01-13	\N	\N
272	1	Wprowadzenie rejestru zmian kolejności lub/i rodzaju operacji w procesach technologicznych.	2025-01-31	2025-01-13	\N	\N
273	1	Próba znalezienia dostawcy zaworu z ustawionym już ciśnieniem 40bar	2025-02-28	2025-01-13	\N	\N
274	1	W przypadku kolejnych reklamacji sprawdzanie szczelności zaworu po ustawieniu ciśnienia 40bar w Agromet	2025-12-31	2025-01-13	\N	\N
275	1	Modernizacja i odnowienie malarni w celu zachowania jakości powłoki malarskiej oraz pakowania siłowników.	2025-02-28	2025-01-13	\N	\N
276	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
328	2	Kalibracja gwintów	\N	\N	\N	\N
329	2	Obniżenie wymiarów w tulei prowadzącej	\N	\N	\N	\N
330	2	Detale okazały się nienaprawialne. Zbrakowano i wykonano nową serię.	\N	\N	\N	\N
277	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
278	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
279	1	Wprowadzenie krzyżowego sprawdzania dokumentacji konstrukcyjnej.	2025-03-07	2025-01-13	\N	\N
280	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
281	1	Analizowanie i reklamowanie stali. Szukanie nowych dostawców o wyższej kulturze jakościowej. Przejście na pręty o większej grubości w celu uniknięcia niedoskonałości powierzchni.	2025-05-31	2025-01-13	\N	\N
282	1	Wprowadzenie krzyżowego sprawdzania dokumentacji konstrukcyjnej.	2025-03-07	2025-01-13	\N	\N
283	1	Wprowadzenie krzyżowego sprawdzania dokumentacji konstrukcyjnej.	2025-03-07	2025-01-13	\N	\N
284	1	Modernizacja i odnowienie malarni w celu zachowania jakości powłoki malarskiej oraz pakowania siłowników (Poprawa ergonomii pracy)/	2025-02-28	2025-01-13	\N	\N
285	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
286	1	Modernizacja malarni i ergonomii pracy. Dodatkowe oświetlenie. Wózki do pakowania.	2025-02-28	2025-01-13	\N	\N
287	1	Modernizacja malarni i ergonomii pracy. Dodatkowe oświetlenie. Wózki do pakowania.	2025-02-28	2025-01-13	\N	\N
288	1	Zmiana konstrukcyjna tulei prowadzącej. Wprowadzenie pasków żywicznych. Zwiększenie średnicy tulei prowadzącej w obszarze pasków.	2025-03-14	2025-01-13	\N	\N
289	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
290	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-01-13	\N	\N
291	1	 Zmiana tłoka i rodzaju uszczelnienia z teflonowego na kompakt.	2025-03-14	2025-01-13	\N	\N
292	1	 Zmiana tłoka i rodzaju uszczelnienia z teflonowego na kompakt.	2025-03-14	2025-01-13	\N	\N
293	1	 Zmiana tłoka i rodzaju uszczelnienia z teflonowego na kompakt.	2025-03-14	2025-01-13	\N	\N
294	1	 Zmiana tłoka i rodzaju uszczelnienia z teflonowego na kompakt.	2025-03-14	2025-01-13	\N	\N
295	1	 Wprowadzono instrukcje ilustracyjne do montażu siłowników.	2024-06-06	2024-06-06	\N	\N
296	1	 Przeszkolono pracowników montażu i mistrzów. 3/NJ/24; 2/PP/25	2025-01-13	2025-01-13	\N	\N
297	1	Zmiany konstrukcyjne w siłownikach polegające na zmianie uch.	2025-04-18	2025-01-13	\N	\N
298	1	Zmiany konstrukcyjne w siłownikach polegające na zmianie uch.	2025-04-18	2025-01-13	\N	\N
299	1	Wprowadzenie nowej instrukcji do kart zmian w celu zapobiegania podobnym incydentom.	2025-04-11	2025-04-11	\N	\N
300	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-04-11	\N	\N
301	1	Zmiana konstrukcyjna tulei prowadzącej. Wprowadzenie pasków żywicznych. Zwiększenie średnicy tulei prowadzącej w obszarze pasków.	2025-03-07	2025-04-11	\N	\N
302	1	Szkolenie pracowników na temat zaistniałej sytuacji.	2025-04-18	2025-04-11	\N	\N
303	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-04-11	\N	\N
304	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-04-11	\N	\N
305	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-04-11	\N	\N
306	1	 Naprawa i uruchomienie automatycznej stacji prób. 	2025-04-18	2025-04-09	\N	\N
307	1	Modernizacja stanowisk prób siłowników do półautomatycznego. Program będzie sterował czasem i ciśnieniem próby. Z każdej próby będzie raport z próby. Przecieki będą monitorowane na podstawie zmiany ciśnienia w czasie dodatkowo spoiny i uszczelnienie główne będzie kontrolowane wzrokowo przez pracownika.	2025-12-31	2025-04-09	\N	\N
308	1	W przypadku powtórnej reklamacji wprowadzenie dodatkowego zabezpieczenia tłoka w postaci punktowania.	\N	\N	\N	Status: praca ciągla
309	1	W przypadku powtórnej reklamacji wprowadzenie dodatkowego zabezpieczenia tłoka w postaci punktowania.	\N	\N	\N	Status: praca ciągla
310	1	W przypadku powtórnej reklamacji wprowadzenie dodatkowego zabezpieczenia tłoka w postaci punktowania.	\N	\N	\N	Status: praca ciągla
311	2	Ponowne szlifowanie i przebierane. 17.04.2025 po ponownym przebraniu na galwanizerni odpadły 3 szt. Reszta do ponownego obniżania.	\N	\N	\N	\N
312	2	Ponowna obróbka	\N	\N	\N	\N
313	2	Drobna obróbka.	\N	\N	\N	\N
314	2	Aktualizacja dokumentacji	\N	\N	\N	\N
315	2	Ponowna obróbka	\N	\N	\N	\N
316	2	Ponowna obróbka	\N	\N	\N	\N
317	2	Ponowna obróbka. Usunięcie korozji.	\N	\N	\N	\N
318	2	Dmontaz, mycie i ponowny montaż	\N	\N	\N	\N
319	2	Ponowna obróbka	\N	\N	\N	\N
320	2	Wprowadzenie zmian	\N	\N	\N	\N
321	2	Detale zbrakowane	\N	\N	\N	\N
322	2	Ponowna obróbka	\N	\N	\N	\N
323	2	Ponowna obróbka	\N	\N	\N	\N
324	2	Natychmiastowa poprawa	\N	\N	\N	\N
325	2	Przepolerowanie śladów po łożysku.	\N	\N	\N	\N
331	2	Detale okazały się nienaprawialne. Zbrakowano i wykonano nową serię.	\N	\N	\N	\N
332	2	Detale okazały się nienaprawialne. Zbrakowano i wykonano nową serię.	\N	\N	\N	\N
333	2	Ponowna obróbka	\N	\N	\N	\N
334	2	Wytrawianie i ponowne chromowanie. Po wykonaniu działań, chrom szczelny.	\N	\N	\N	\N
335	2	Demontaż i poprawa.	\N	\N	\N	\N
336	2	Ponowna obróbka	\N	\N	\N	\N
337	2	Ponowna obróbka	\N	\N	\N	\N
338	2	Ponowne wiercenie	\N	\N	\N	\N
339	2	Poprawa gwintów	\N	\N	\N	\N
340	2	Wykonanie obróbki	\N	\N	\N	\N
341	2	Usunięcie korozji.	\N	\N	\N	\N
342	2	Wykonanie obróbki/polerowanie/honowanie	\N	\N	\N	\N
343	2	KZ/Aktualizacja programu	\N	\N	\N	\N
344	2	Aktualizacja dokumentacji	\N	\N	\N	\N
345	2	Aktualizacja dokumentacji	\N	\N	\N	\N
346	2	Kalibrowanie gwintu	\N	\N	\N	\N
347	2	Wykonanie obróbki.	\N	\N	\N	\N
348	2	Wykonanie obróbki.	\N	\N	\N	\N
349	2	Demontaż i uszczelnienie dodatkową spoiną miejsc cieknących	\N	\N	\N	\N
350	2	Wykonanie obróbki.	\N	\N	\N	\N
351	2	Dokładna analiza czasów	\N	\N	\N	\N
352	2	Detale zostały dopasowane konstrukcyjnie	\N	\N	\N	\N
353	2	Sprawdzenie stanu oprzyrządowania	\N	\N	\N	\N
354	2	Detale zagładzono pilnikiem	\N	\N	\N	\N
355	2	Do poprawy, ściągnąć nadmiar smaru, odpowiednio ustawić.	\N	\N	\N	\N
356	2	Badanie wykonania, oprzyrządowania	\N	\N	\N	\N
357	2	Poprawić, wykonać frezowanie, KZ!	\N	\N	\N	\N
358	2	Poprawa, zbrakowane spirale wchodzące na zatoczenie. Zmiana programu	\N	\N	\N	\N
359	2	Natychmiastowe wprowadzenie zmian 	\N	\N	\N	\N
360	2	Obudowy zostały zbrakowane, dorobiono nowe.	\N	\N	\N	\N
361	2	Usunięcie korozji.	\N	\N	\N	\N
362	2	Usunięcie korozji.	\N	\N	\N	\N
363	2	Do przebrania. 	\N	\N	\N	\N
364	2	Poprawa spirali- polerowanie	\N	\N	\N	\N
365	2	Czyszczenie, malowanie	\N	\N	\N	\N
366	2	Wykonać odpowiednie oprzyrządowanie	\N	\N	\N	\N
367	2	Obcięcie i wykonanie nowego tłoczyska, 	\N	\N	\N	\N
368	2	Po wykonanych próbach przetransportowane do poprawy	\N	\N	\N	\N
369	2	Ręczny szlif detali	\N	\N	\N	\N
370	2	Analiza sytuacji, dokładna kontrola całego zlecenia	\N	\N	\N	\N
371	2	Przegląd wszystkich łożysk	\N	\N	\N	\N
372	2	Wykonanie obróbki	\N	\N	\N	\N
373	2	Czyszczenie po malowaniu papierem ściernym?	\N	\N	\N	\N
374	2	Kilkukrotne prostowanie, szlifowanie	\N	\N	\N	\N
375	2	Kilkukrotne prostowanie, szlifowanie	\N	\N	\N	\N
376	2	Detale zatrzymano i wysłano do wytrawnienia i ponownego chromowania.	\N	\N	\N	\N
377	2	Do wytrawienia i polerowania. Wyszły idealne. 	\N	\N	\N	\N
378	2	Skrócenie rurek w narzędziowni.	\N	\N	\N	\N
379	2	Usunięcie korozji odrdzewiaczem.	\N	\N	\N	\N
380	2	Usunięcie korozji odrdzewiaczem.	\N	\N	\N	\N
381	2	Stoczenie tłoka i wciśnięcie na właściwy wymiar.	\N	\N	\N	\N
382	2	Toczenie i dostosowanie wymiarów	\N	\N	\N	\N
383	2	Analiza sytuacji, dokładna kontrola całego zlecenia	\N	\N	\N	\N
384	2	Demontaż i ponowna obróbka.	\N	\N	\N	\N
385	2	Wytrawianie, polerowanie i chromowanie w nowszej wannie	\N	\N	\N	\N
386	2	Braki, wykonanie na nowo.	\N	\N	\N	\N
387	2	Demontaż zaworów i montaż ospowiednich. Złożenie reklamacji do klienta	\N	\N	\N	\N
388	2	Wprowadzenie warunkowych operacji polerowania.	\N	\N	\N	\N
389	2	Wprowadzenie warunkowych operacji polerowania.	\N	\N	\N	\N
390	2	Natychmiastowa korekta dokumentacji	\N	\N	\N	\N
391	2	Przekazane do ponownego polerowania- w dalszym ciągu wychodzą dziury.	\N	\N	\N	\N
392	2	Detale zostały zbrakowane, wykonano nowe.	\N	\N	\N	\N
393	2	Do wytrawienia przekazano 55 szt	\N	\N	\N	\N
394	2	Sztuki poprawione szlifierką.	\N	\N	\N	\N
395	2	Detale zostały zbrakowane, wykonano nowe.	\N	\N	\N	\N
396	2	Poprawa i ponowna obróbka	\N	\N	\N	\N
397	2	Demontaż, zamontowanie prawidłowego tłoczyska.	\N	\N	\N	\N
398	2	Dopuszczenie warunkowe detali	\N	\N	\N	\N
399	1	Regeneracja myjni- montaż	2024-03-04	2024-03-04	\N	regeneracja w trakcie 
400	1	dorobić głowicę fi 40	2024-02-29	2024-02-29	\N	dorobiono dwie głowice
401	1	Kosze do mycia	2024-09-30	2024-10-30	\N	kosze zostały zrobione
402	1	Wady materiału	2024-10-22	2024-10-22	\N	\N
403	1	zabezpieczenie tłoczysk przed zanieczyszczeniami	2024-02-12	2024-02-12	\N	optymalizacja procesu
404	1	Zbadanie sprawy	2024-07-22	2024-07-22	\N	błąd pracownka, nie do ustalenia
405	1	Wprowadzednie zmian do dokumentacji	2024-07-22	2024-07-16	\N	Poprawiono rysunek
406	1	Zwiększona kontrola spawacza, dorobienie osłonek.	2024-08-15	2024-09-08	\N	osłonki dorobiono
407	1	zabezpieczenie tłoczysk przed zanieczyszczeniami	2024-02-12	2024-02-12	\N	optymalizacja procesu
408	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-12	\N	optymalizacja procesu
409	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-12	\N	optymalizacja procesu
410	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-12	\N	optymalizacja procesu
411	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-12	\N	optymalizacja procesu
412	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-12	\N	optymalizacja procesu
413	1	-dobranie odpowied. Parametrów toczenia  - wykonanie prób na szlifierce	2024-02-12	2024-02-21	\N	optymalizacja procesu, wykonano próby
414	1	usówanie wiórów i zanieczysczeń zgodnie z mażliwościami	2024-02-12	2024-02-12	\N	praca ciągła
415	1	usówanie wiórów i zanieczysczeń zgodnie z mażliwościami	2024-02-12	2024-02-12	\N	praca ciągła
416	1	spawanie zgodnie z rysunkiem	2024-02-12	2024-02-21	\N	Odbyło się szkolenie pracowników
417	1	-sprawdzenie istotności wypustek - ustawienie głowicy	2024-02-12	2024-02-12	\N	głowica została prawidłowo ustawiona, pracownicy zostali poinformowani przez mistrza
418	1	-sprawdzenie istotności wypustek - ustawienie głowicy	2024-02-12	2024-02-12	\N	głowica została prawidłowo ustawiona, pracownicy zostali poinformowani przez mistrza
419	1	Dobranie parametrów toczenia,. Próba na szlifierce.	2024-02-18	2024-02-18	\N	optymalizacja procesu toczenia (uwaga-brak inf o zmianie materiału)
420	1	Założyć mistrza do kontroli jakości	2024-02-23	2024-02-26	\N	wprowadzono mistrza
494	1	Poprawa dokumentacji i wykonanie noża ISCAR	2024-04-03	2024-03-26	\N	Dokmentacja została poprawiona. Nóż został wykonany.
495	1	Dodanie rys ustawnych do dokumentacji technologicznej	2024-04-22	2024-04-04	\N	Dodano rysy ustawne do rysunku
421	1	Zamiana technologii, wiercenie po spawaniu	2024-03-04	2024-07-14	\N	czekamy na ucho. 22.04 czekamy na kolejną seriie,badania w trakcie.08.07.24 działania sa w ostatecznej fazie. 07.14.24 wporwadzono nową odkówkę i zmiany w technologii. Probelm z czasem pomiędzy wykonaniem detali w donej/ starej wersji
422	1	- wprowadzenie samokontroli  - sprawdzenie 1 sztuki wyrobu	2024-02-19	2024-02-25	\N	wprowadzono karty kontrolne 
423	1	Założyć mistrza do kontroli jakości	2024-02-23	2024-02-26	\N	wprowadzono mistrza
424	1	Założyć mistrza do kontroli jakości	2024-02-23	2024-02-26	\N	wprowadzono mistrza
425	1	Dobranie parametrów toczenia,. Próba na szlifierce.	2024-02-19	2024-02-23	\N	sprawdzenie przy kolejnej serii. Wprowadzono zaminy w programach i uwagi o stępieniu krawędzi na rysunkach (19.03). UWAGA!!! W przypadku zmiany rury (otworu) konieczne są zmiany programu
426	1	Założyć mistrza do kontroli jakości	2024-02-23	2024-02-26	\N	wprowadzono mistrza
427	1	znienić konstrkcję- faza pod spoinę	2024-02-19	2024-02-19	\N	wprowadzono kartę zmian
428	1	Dobranie parametrów toczenia,. Próba na szlifierce.	2024-02-19	2024-02-19	\N	optymalizacja procesu toczenia (uwaga-brak ing o zmianie materiału)
429	1	po toczeniu pozbyć się otuliny, tłoczyska układać "gołe" w czystej palecie i przekładać folią	2024-02-19	2024-02-19	\N	wprowadzono zmiany
430	1	Dobranie parametrów toczenia,. Próba na szlifierce.	2024-02-19	2024-02-12	\N	optymalizacja procesu toczenia (uwaga-brak ing o zmianie materiału)
431	1	Przegląd myjni na produkcji do rur	2024-03-04	2024-03-04	\N	zakup odp. Preparatu
432	1	Dobranie parametrów toczenia,. Próba na szlifierce.	2024-02-12	2024-02-12	\N	optymalizacja procesu toczenia (uwaga-brak ing o zmianie materiału)
433	1	Stworzenie uchwytu, haka	2024-02-26	2024-02-23	\N	Wprowadzono osłonki na zgarniacze. Trwa obserwacja, w razie konieczności powstanie hak/uchwyt.
434	1	Zmiana rys., wprawadzenie zmian konstrikcyjnych, dłuższy gwint	2024-03-04	2024-03-15	\N	Rysunek został zaktualizowany
435	1	sprawdzić odprężanie u kooperanta	2024-03-04	2024-04-16	\N	Wpisano uwagi na dokumentacji technologicznej. Wprowadzono czytelny rysunek.
436	1	zmienić proces, dodać operacje kalibracji	2024-03-04	2024-02-20	\N	proces technologiczny jest prawidłowy. Należy dopilnować przestrzegania procesu, przeszkolić odpowiednio pracowników.
437	1	zmienić proces, dodać operacje kalibracji	2024-03-05	2024-02-21	\N	proces technologiczny jest prawidłowy. Należy dopilnować przestrzegania procesu, przeszkolić odpowiednio pracowników.
438	1	wprowadzenie kart pomiarowych	2024-03-04	2024-04-22	\N	Wprowadzono kartę kontrolną
439	1	sprawdzić odprężanie u kooperanta	2024-03-04	2024-04-16	\N	Wpisano uwagi na dokumentacji technologicznej. Wprowadzono czytelny rysunek.
440	1	Sprawdzenie mat od dostawcy, zmiana tech. Dodanie operacji polerowania po cięciu, zakup 5 latarek	2024-03-04	2024-03-03	\N	Sprawdzanie korozji przed i po cięciu na piłach- praca ciągła. Szkolenie pracowników na cięciu.
441	1	Sprawdzenie mat od dostawcy, zmiana tech. Dodanie operacji polerowania po cięciu, zakup 5 latarek	2024-03-04	2024-03-04	\N	Sprawdzanie korozji przed i po cięciu na piłach- praca ciągła. Szkolenie pracowników na cięciu.
442	1	Trasowanie rur i korpusu do spawania	2024-03-04	2024-03-05	\N	Korpus jest robiony na TLC i nie można trasować w czasie toczenia. Wpisano operację trasowania ręcznego. Nie można wprowadzić operacji trasowania na maszynie.
443	1	poprawa technologii	2024-03-04	2024-02-22	\N	wprowadzono zmiany technologiczne
444	1	poprawa technologii	2024-03-04	2024-02-22	\N	wprowadzono zmiany technologiczne
445	1	zrobic zamek pod CO2	2024-03-04	2024-04-12	\N	Wprowadzono kartęzmian KZ 19/2024
446	1	naprawa rury	2024-02-29	2024-02-29	\N	rura została naprawiona
447	1	ustalić właściwy proces	2024-03-04	2024-02-22	\N	wprowadzono zmiany technologiczne
448	1	Przeprowadzenie szkolenia pracowników	2024-03-04	2024-02-27	\N	szkolenie przeprowadzono
449	1	Sprawdzić wiertła i narzędzia na centrum	2024-03-04	2024-03-04	\N	sprawdzono sprzęt, poinstruowano pracowników
450	1	Przeszkolenie pracwoników. Stosowanie osłonek do spawania. Zakup szczotek do gwintów na tokarkach.	2024-03-04	2024-07-01	\N	Pracownicy zostali przeszkoleni w sprawie użytkowania osłonek. Szczotki zamowione przez Kierownika Jakości 20.06.24/08.07.24 Trwaja badania, poszukujemy sposobu na dopracowanie metody.01.07.24 porzycono temat szczotek, wprowadzono nowe płytki do obróbki gwintów
451	1	Przeszkolenie pracwoników. Stosowanie osłonek do spawania. Zakup szczotek do gwintów na tokarkach.	2024-03-04	2024-07-01	\N	Pracownicy zostali przeszkoleni w sprawie użytkowania osłonek. Szczotki zamowione przez Kierownika Jakości 20.06.24/08.07.24 Trwaja badania, poszukujemy sposobu na dopracowanie metody.01.07.24 porzycono temat szczotek, wprowadzono nowe płytki do obróbki gwintów
452	1	Przeszkolenie pracwoników. Stosowanie osłonek do spawania. Zakup szczotek do gwintów na tokarkach.	2024-03-04	2024-07-01	\N	Pracownicy zostali przeszkoleni w sprawie użytkowania osłonek. Szczotki zamowione przez Kierownika Jakości 20.06.24/08.07.24 Trwaja badania, poszukujemy sposobu na dopracowanie metody.01.07.24 porzycono temat szczotek, wprowadzono nowe płytki do obróbki gwintów
453	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-03-15	\N	Wprowadzono zmiany w dokumentacji technologicznej
454	1	Sprawdzenie dostępności sprawdzianu tłokowego fi 34 h7	2024-03-04	2024-02-24	\N	Posiadamy jedynie sprawdzian h8. h7 zlecono do zakupu
455	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-02-27	\N	wprowadzono zmiany do dokumentacji technologicznej
456	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-02-27	\N	wprowadzono zmiany do dokumentacji technologicznej
457	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-02-27	\N	wprowadzono zmiany do dokumentacji technologicznej
458	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-02-27	\N	wprowadzono zmiany do dokumentacji technologicznej
459	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-04	2024-02-23	\N	wprowadzono zmiany do rysunku
460	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-02-27	2024-02-27	\N	wprowadzono zmiany do rysunku
461	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-03-11	2024-02-28	\N	wprowadzono zmiany do opisówki
462	1	Prześledzenie i analizna poszczególnych etapów produkcji, w celu wykryciaprzyczyn powstawania uszkodzeń w tłoczyskach	2024-03-11	2024-04-20	\N	Problemy:1 "plamy", "tarka" na powierzni chrom: owal powstały przez zbieranie mat. podczas szlif. wstępnego- szlif na gotowo nie usuwał mat, powstały plamy, nie zabielone, chrom to uwidaczniał. Należy zmienić operacje- mniejszy naddatek przy toczeniu i szlif.2: :dziury" nadzor nad operacjami pol. przed i po chrom. Większa kontrolna/konieczna zmiana tech.
496	1	Błąd pracownika. Odwrócona tolerancja na szlifierce. Przeszkolenie pracownika	2024-04-04	2024-04-04	\N	Pracownicy zostali przeszkoleni
497	1	Błąd pracownika. Odwrócona tolerancja na szlifierce. Przeszkolenie pracownika	2024-04-04	2024-04-04	\N	Pracownicy zostali przeszkoleni
463	1	Prześledzenie i analizna poszczególnych etapów produkcji, w celu wykryciaprzyczyn powstawania uszkodzeń w tłoczyskach	2024-03-11	2024-04-21	\N	Problemy:1 "plamy", "tarka" na powierzni chrom: owal powstały przez zbieranie mat. podczas szlif. wstępnego- szlif na gotowo nie usuwał mat, powstały plamy, nie zabielone, chrom to uwidaczniał. Należy zmienić operacje- mniejszy naddatek przy toczeniu i szlif.2: :dziury" nadzor nad operacjami pol. przed i po chrom. Większa kontrolna/konieczna zmiana tech.
464	1	Prześledzenie i analizna poszczególnych etapów produkcji, w celu wykryciaprzyczyn powstawania uszkodzeń w tłoczyskach	2024-03-11	2024-04-22	\N	Problemy:1 "plamy", "tarka" na powierzni chrom: owal powstały przez zbieranie mat. podczas szlif. wstępnego- szlif na gotowo nie usuwał mat, powstały plamy, nie zabielone, chrom to uwidaczniał. Należy zmienić operacje- mniejszy naddatek przy toczeniu i szlif.2: :dziury" nadzor nad operacjami pol. przed i po chrom. Większa kontrolna/konieczna zmiana tech.
465	1	Przeszkolenie pracowników w sprawie prawidłowego zakładania tulejek ochronnych	2024-03-11	2024-03-04	\N	Pracownicy zostali przeszkoleni w sprawie prawidłowego zakładania tulejek ochronnych
466	1	Poprawienie dokumentacji technologicznej. Rysunki dostajemy gotowe od Lukasa. Czekamy aż Tuchola dogada się z Lukasem.24.06.24 w dalszym ciagu konferencja z Lukasem jest nie możliwa do przeprowadzenia z winy klienta.	2024-03-25	2024-07-01	\N	 Czekamy aż Tuchola dogada się z Lukasem.Problemy z komunikacją.01.07.24 Rozmowy nie przyniosły rezultatów. A razie wątpliwości należy drukować rysunki w formacie A3
467	1	Przeszkolenie pracownika	2024-03-25	2024-03-01	\N	Pracownicy zostali przeszkoleni w sprawie uzytkowania prawidłowego pogłębiacza
468	1	Przeszkolono pracownika, uczulowno na konieczność pracy w zespole	2024-03-25	2024-03-12	\N	Pracownik Jerzy Telingo został przeszkolony w zakresie szlifowania tuleji cylindra CJ-S428-100/1.00, oraz prawidłowego ustawiania polerki.
469	1	Błąd wykonania tłoczyska (praw. Niewłaściwie wykonane szlofowanie); Błędnie wystawiona karta dopuszczenia. 	2024-03-25	2024-03-15	\N	Kontrolerzy zostali zopatrzeni w latarki w celu sprawniejszego sprawdzania chromu.
470	1	Prześledzenie i analizna poszczególnych etapów produkcji, w celu wykryciaprzyczyn powstawania uszkodzeń w tłoczyskach	2024-03-25	2024-04-20	\N	Problemy:1 "plamy", "tarka" na powierzni chrom: owal powstały przez zbieranie mat. podczas szlif. wstępnego- szlif na gotowo nie usuwał mat, powstały plamy, nie zabielone, chrom to uwidaczniał. Należy zmienić operacje- mniejszy naddatek przy toczeniu i szlif.2: :dziury" nadzor nad operacjami pol. przed i po chrom. Większa kontrolna/konieczna zmiana tech.
471	1	Cylider do demontazu. Prawdopodownie źle wykonana obróbka.	2024-03-25	2024-03-15	\N	Po demontazu wykryto uszkodzoną powierzchnię między uszczelkami (odcisk od szczęk). Bład operatora
472	1	Spawanie na zwykłym obrotniku a nie na automacie	2024-03-25	2024-03-25	\N	Przezkolenie pracownika
473	1	Uczulenie mistrzow i kontrolerów odnośnie kontroli i zwalniania detali. Reklamacja u dostawcy.	2024-03-25	2024-03-25	\N	Pracownicy zostali poinstruowani, dostawca powiadomiony. Operatorzy pił przeszkoleni w sprawie sprawdzania rur po cięciu, dostali dodatkowe latarki
474	1	Zmiana procesu technologicznego (dodanie operacji polerowania rury nurnika przed i po chrom. Oraz spawaniu); właściwe szlofiwanie	2024-03-25	2024-03-15	\N	Wprowadzono zmiany w procesie technologicznym, dodano dodatkowe operacje polerowania w rurze nurnika CN-S36-70/2.01
475	1	Sprawdzenie przyczyny, sprawdzenie urzytych narzędzi.	2024-03-25	2024-03-15	\N	Operatorowi zablokowało się wiertło w detalu. Później prawdopodobnie wiercił tym samym wiertłem bez sprawdzania detalu. Zaleca się dokładniejsza kontrolę przez operatorów i mistrzów.
476	1	Prawidłowe zabezpieczenie w transporcie. Zakup nakładki do izolacji rur (tulejki gąbkowe)- osłona krańców tłoczyska. Wymiana rolek na obróbce na nowe (poliuretanu?) + nowe stanowski dla dużych średnic (kołka z wózków?)	2024-03-25	2024-07-08	\N	Rolki zostały wymienione. Zakupiono ochronki na tłoczyska. 05.05.24 czekamy na zakup dodatkowych średnic osłonek, dotychczasowe spełniają zadanie. Na mniejsze średnice wykorzystuje się folię bombelkową.08.07.24 zakupiono na wszytskie potrzebne średnice
477	1	Wzmożona kontrole materiałów z odzysku. 	2024-03-25	2024-03-18	\N	Nie używać więcej materiału z odzysku do niniejszego nurnika
478	1	Stworzenie karty instruktarzowej 	2024-03-25	2024-03-25	\N	Karta została wykonana
479	1	Dokonanie odpowiednich zmian w dokumentacji technologiczno-konstrukcyjnej.	2024-03-25	2024-04-08	\N	Wprowadzono nowe rys tuleji cylindra i obudowy
480	1	Przyrząd do opracowania i wykonania.	2024-04-15	2024-03-29	\N	Przyrząd został wykonany
481	1	Przyrząd do opracowania i wykonania.	2024-04-15	2024-03-29	\N	Przyrząd został wykonany
482	1	Napisać WPS dla poszczególnych rurek w zależności od średnicy; Przeszkolenie spawaczy odnośnie prawidłowego spawania.	2024-03-25	2024-04-21	\N	Pracownicy zostali przeszkoleni w zakresie spawania rurki zasilającej. Stworzono WPS dla rurek.
483	1	Znalezienie sposobu na pozbycie się pierścieni z kanałka (posów)	2024-03-25	2024-04-15	\N	Sposób nie został znaleziony. Należy na bierząco analizować sytuację przy kolejnych seriach.
484	1	Sprawdzenie czy piaskowanie przynosi efekty i czy należy wprowadzić dodatkowa operację obróbki ślusarskiej.	2024-03-25	2024-03-18	\N	Pozostawienie stanu aktualnego. Nacisk na większa kontrolę przez Mistrzów
485	1	Przeprowadzenie szkolenia pracowników; Stworzenie kart instruktarzowych dotyczących prawidłowego spawania	2024-03-26	2024-03-21	\N	Prazownik Marteusz Kurowski został przeszkolony w zakresie spawania detali. Stworzono karty instruktarzowe dotyczące prawidłowo wykonanaej spoiny.
486	1	Wprowadzenie zmian w dokumentacji technologicznej 	2024-04-08	2024-03-29	\N	Dodano operację kalibrowania
487	1	1. We  wcześniejszym zamówieniu rura była bardzo złej jakości, należy skontrolować jej stan, pozostawiony na magazynie. 2 Przestawienie się na mycie i pakowanie R-ów na Produkcji- gdy zamontują nową myjkę. 3 Dodatkowa operacja polerowania po cięciu.	2024-04-08	2024-04-15	\N	Pozostała rura, lącznie z nową dostawą sa w dobrym stanie. Przestawienie się na pakowanie na produkcji po zamantowaniu myjki.
488	1	Zaginęły podczas transportu wewnętrznego zaślepki. Należy je znaleźć oraz zakupić nowe.	2024-03-29	2024-04-03	\N	Zaślepki nie zaginęły, zamówiono za małą ilość, która została zamontowana do siłowników.
489	1	Zbadanie sprawy	2024-06-24	2024-10-30	\N	Nie ma możliwości wyeliminowania problemu technologicznie, pracownicy są zobowiązani do usówania wiórów ręcznie.
490	1	Dokonanie zmian w dokumentacji technologicznej. Produkcja powinna wykonywać siłowniki wg dokumentacji technologicznej. W przypadku zmian w zamówiniu, marketing jest zobowiązany do poinformowania i pilotowania zmian na Produkcji	2024-03-25	2024-03-25	\N	Wprowadzono zmiany w dokumentacji. Ral 1003 zmieniono na 7024 (szary grafit)
491	1	Wprowadzenie zmian w dokumentacji technologicznej 	2024-04-08	2024-03-29	\N	Dodano operację kalibrowania
492	1	Wprowadzenie zmian w dokumentacji technologicznej 	2024-04-08	2024-03-29	\N	Dodano operację kalibrowania
493	1	Zlecenie i kontrola czyszczenia palet	2024-04-09	2024-03-29	\N	Wprowadzono kontrolę czystosci palet
498	1	Prawidłowe zabezpieczenie w transporcie. Zakup nakładki do izolacji rur (tulejki gąbkowe)- osłona krańców tłoczyska. 	2024-04-15	2024-04-29	\N	Zakupiono osłonki
499	1	Błąd pracownika. Przeszkolenie pracownika- nie powinien sam wprowadzać zmian do programu. 	2024-04-08	2024-04-21	\N	Pracownicy zostali przeszkoleni
500	1	Uporządkowanie miejsca na montazu przy stanowisku Kontroli Jakości	2024-04-15	2024-04-29	\N	Miejsce zostało uporządkowane, praca ciągła.
501	1	Zbadanie sprawy; stworzenie karty kontrolnejnarzędzie zostało zgłoszone do naprawy 50042349	2024-04-15	2024-04-30	\N	Narzędzie zostało wykonane. Pracowników nie potrafiących zagniatać należy szkolić w razie potrzeby.
502	1	Materiał był kupiony na próbę- wadliwy	2024-04-15	2024-04-07	\N	Nie kupować materiału tego producenta
503	1	Materiał był kupiony na próbę- wadliwy	2024-04-08	2024-04-08	\N	Nie kupować materiału tego producenta
504	1	Sprawa do zbadania	2024-04-15	2024-04-08	\N	Wprowadzono karte zmian (KZ17/2024)
505	1	Opracowanie działań zmierzających do zagniatania łożysk wahliwych na produkcji	2024-04-15	2024-06-10	\N	06.05.24 obecnie trwają próby, najpilniejszą kwestią jest zaggniatanie dużych średnic.13.05.24 Próby wykazały, że łożyska się stępiają (zgarniacze)10.06.24 Próby nie przyniosły oczekiwanych rezultatów. Temat został przesunięty na nieokreślona przyszłość.
506	1	Wprowadzenie zmian do dokumentacji technologicznej. 	2024-04-29	2024-04-21	\N	Wprowadzono uwagę o wykonaniu rys
507	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
508	1	Wprowadzenie zmian do dokumentacji technologicznej. Wprowadzenie operacji obróbki ręcznej? Ewidentny błąd operatora.	2024-04-29	2024-07-08	\N	06.05.24 testy zmierzające do zmian w dokumentacji w trakcie. 08.07.24 do końca miesiąca powinny się zakończyć analizy.
509	1	Przywiązanie szczególnej wagi do czystości palet. Czyszczenie (dmuchanie) tłoczysk po toczeniu (przed i po chromowaniu). Stworzenie instrukcji dla pracowników.	2024-04-29	2024-06-10	\N	28.04.24 Wprowadzono zmianty w dokumentacji- uwagi o czyszczeniu. Instrukcja w trakcie.06-10 instrukcja
510	1	Stworzenie systemu nadzoru nad czystościa na malarni	2024-04-29	2024-04-30	\N	06.05.24 Stworzono karty dotyczące czystości na stanowiskach. Wprowadzenie w trakcie. Przesunięcie zmian na koniec sierpnia.
511	1	Chrom został powłozony po raz drugi- odpadło 6 sztuk. Problem do zbadania	2024-04-26	2024-08-09	\N	06.05.24 Sztuki zostały wytrawione, czekamy na analizę. 10.06.24 Próbki w trakcie analizy, czekamy na wyniki badań. 08.07.24 w dalszym ciągu nie ma wyników analizy. 09.08.24 wyniki analizy wskazują na wady obróbki, występującą korozję, bądź wady materiałowe. Przekazane do dalszej analizy.
512	1	Sprawa do zbadania	2024-04-29	2024-07-08	\N	06.05.24 testy zmierzające do zmian w dokumentacji w trakcie. 08.07.24 do końca miesiąca powinny się zakończyć analizy.
513	1	Wprowadzenie zmian do dokumentacji technologicznej. 	2024-04-29	2024-04-24	\N	Poszerzono tolerancję szerokości kanałka 15 (+0,2 +0,1)
514	1	Wprowadzenie zmian do dokumentacji technologicznej. 	2024-04-29	2024-05-13	\N	Zmiana długości podtoczenia fi 83 z L=2 na L=3 w korpusie CJ2E-80/1.02D
515	1	Rozbierzności między opisówka i rysunkiem, należy wprowadzić zmiany technologiczne.	2024-04-29	2024-04-21	\N	Wprowadzenie zmian w opisówce
516	1	Wprowadzenie zmian do dokumentacji technologicznej. 	2024-04-29	2024-04-24	\N	Wprowadzono uwagi na rysunku
517	1	Wprowadzić zmiany o dokumentacji	2024-04-19	2024-04-19	\N	Rysynki i opisówki zostały zmienione.
518	1	Sprawdzić stan narzędzi (cofka)	2024-04-24	2024-04-30	\N	Sprawdzono stan narzędzi, wynika ewidentny błąd praconika (został przeszkolony)
519	1	Zatrzymanie serii. Sprawdzenie stanu magazynowego i podjęcie dalszych działań	2024-04-25	2024-04-22	\N	Seria została zatrzymana. Przeprowadzano ponowne próby na wszystkich siłownikach.
520	1	Wprowadzenie zmian technologicznych, Do każdego odbiorcy przyporządkować inny kod.	2024-04-29	2024-05-10	\N	Wprowadzono uwagi na rysunku
521	1	Wprowadzić zmiany o dokumentacji	2024-04-19	2024-04-19	\N	Zmiany wprowadzono
522	1	Zbadanie sprawy. Do dotychczasowej serii odciąć i przyspawać nowe ucho. Możliwe przyczyny: krzywo wypalone ucha, przekroczenie na frezowaniu. Możliwa zmiana technologii.	2024-05-10	2024-05-13	\N	Prawdopodobną przyczyną jest wadliwy przyrząd spawalniczy- zotał wysłany do regeneracji (poprawiony)
523	1	Użyto materiału zastepczego, co wymagało dodatkowych operacji. Błąd operatora- uczulić i przeszkolić.	2024-05-06	2024-04-30	\N	Przeszkolono operatora. Ewidentny pośpiech.
524	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-05-10	2024-04-24	\N	Zmiany wprowadzono niezwłocznie 
525	1	Błąd operatora. Należy stworzyć wzornik i wprowadzić zmiany w technologii.	2024-05-10	2024-05-06	\N	Wzornik został zaprojektowany i stworzony. Wprowadzano zmiany technologiczne.
526	1	Zbadanie problemu (cofka)	2024-05-10	2024-05-16	\N	Należy wprowadzić zmiany  w dokumentacji technologicznej- zmienić rys. na mniejsza średnicę. Potencjalnie należy kupić nowe wiertło z cofką. 16.05.24 Otwór zasilający fi 10 zostaje, wykonanie standardowe. Nie ma potrzeby kupowania nowego. Mistrz Produkcji powinien dopilnować aby narzędzia były dostępne.
527	1	Dokonanie zmian w dokumentacji technologicznej.	2024-05-13	2024-05-08	\N	wprowadzono zmiany do dokumentacji technologicznej
528	1	Dokonanie zmian w dokumentacji technologicznej.	2024-05-13	2024-05-09	\N	wprowadzono zmiany do dokumentacji technologicznej
529	1	Dokonanie zmian w dokumentacji technologicznej.	2024-05-13	2024-05-10	\N	wprowadzono zmiany do dokumentacji technologicznej
530	1	Błąd pracownika, ewidentny pośpiech i niedbałość. Wyjątkowa sytuacja- należy przeszkolić pracownika	2024-05-20	2024-06-17	\N	Odbyło się szkolenie pracowników
531	1	Nie było odpowiedniego przyrzadu do wciskania. Pracownik próbował wcisnać siłowo. Detale zostały sprowadzone na produkcję, rozwiercono tam otwór i wciśnięto tuleje raz jeszcze. Należy wykonać odpowieni przyrząd.	2024-05-27	2024-06-17	\N	Przyrząd został wykonany
532	1	Wydano z rozdzieli 10 szt denek starego typu z trzpieniem fi 8., otwór w uchu - fi 10, przesunięcie w trkcie spawania spowodowało 6 szt braków. Pracownik montował i spawał tuleje do ucha na trzpieniu fi 19 zamiast fi 20. Wystapiły przesunięcia tulejek względem otworu w giętym uchu (niezachowana jednakowa grubość ścianek tuleji)Ad 1 Do starej wersji obudowy należy dorobić nowy przyrząd (trzpień). Nowa wersja- karta zmian po skończonych badaniach. Ad 2 Sprawdzić karty zmian, sprawdzić stany magazynowe denek.	2024-05-27	2024-06-18	\N	Z rozdzielni wycofano 9 kolenych sztuk. (13.05.24)Przyrząd został wykonany
533	1	Uszkodzenia, obicia nurnika przez pracowników na chromowni. Pracownik nie powinien pracować sam. Sprawdzić czy można przerobić pryzmę do polerki na dłuższą	2024-05-27	2024-06-03	\N	Analiza wykazała, że nie można wydłuzyć pryzmy- uniemożliwiłoby to pracę. Stworzono osłonę na części glowicy
573	1	Przeszkolenie pracownika, zbadanie sprawy	2024-07-10	2024-08-05	\N	nastapiła zmiana odkuwki
730	1	Szkolenie pracowników	2024-12-03	2024-12-03	\N	Szkolenie się odbyło
534	1	Doraźnie użyto zaślepki transportowej z tworzywa sztucznego. Należy przerobić system podłączenia	2024-05-27	2024-05-16	\N	Zmieniono kierunek zasilenia. Otwór M20x1,5 jest zasilany a drugi gwint jest zaślepiony                             
535	1	Doraźnie użyto zaślepki transportowej z tworzywa sztucznego. Należy przerobić system podłączenia	2024-05-27	2024-05-13	\N	Przerobiono system podłczenia.
536	1	Stworzenie karty pomiarowej oraz przeszkolenie pracowników	2024-06-03	2024-06-03	\N	05.26.24 wprowadzono kartę pomiarową/Odbyło się szkolenie pracownika.
537	1	Wprowadzenie zmian do dokumantacji. Problem powtarzający się, trwają badania.	2024-06-24	2024-07-08	\N	06.05.24 testy zmierzające do zmian w dokumentacji w trakcie. 08.07.24 do końca miesiąca powinny się zakończyć analizy.
538	1	Przeprowadzenie analizy jak sposób przechowywania/ pakowania detali wpływa na możliwość występowania wżerów. 	2024-06-24	2024-06-24	\N	praca ciągła
539	1	Dokonanie zmian w dokumentacji technologicznej.	2024-05-17	2024-05-16	\N	wprowadzono zmiany do dokumentacji technologicznej
540	1	Należy zmienić średnicę rysunkową tulejki (fi 12) na fi 11,9 (0;-0,1)	2024-05-27	2024-05-17	\N	Wprowadzono zmianę średnicy z fi 12 na fi 12 (-0,1;-0,2)- KZ 30/2024. Podczas działań stwierdzono brać mycia detaly i wióry w otworze fi8- należy zgłosić do kooperanta.
541	1	Przeprowadzenie analizy jak sposób przechowywania/ pakowania detali wpływa na możliwość występowania wżerów. 	2024-06-24	2024-06-24	\N	praca ciągła
542	1	Zbadanie problemu	2024-05-27	2024-05-21	\N	Analiza wykazała, że wymiar 12 musi pozostać, ponieważ ucho CJ-S573-63/1.02-1 jest przerabiane na ucho CT-S354-40/1.02-1 (które jest skracane o 6mm)
543	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
544	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-10-07	2024-09-23	\N	zmiany wpowadzono
545	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
546	1	Błąd operatora- należy przeprowadzić szkolenie. Stworzenie karty pomiarowej	2024-06-15	2024-05-24	\N	Szkolenie  przeprowadzone 28.05.24 (błąd pracowwnika- stępienie płytki). Karta wprowadzona.
547	1	Wprowadzenie odpowiednich zmian technologicznych- wkręcanie ucha na montażu.	2024-06-16	2024-06-26	\N	Wprowadzono zmiany
548	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-06-17	2024-05-28	\N	Rysunek został zaktualizowany
549	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-06-18	2024-05-28	\N	Wprowadzono operację (13) trasowania
550	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
551	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
552	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-06-10	2024-05-28	\N	wprowadzono zmiany do dokumentacji technologicznej
553	1	Zbadanie sprawy	2024-06-28	2024-06-24	\N	03.06.24. Pozsostała rura (85x6)-53m została sprawdzona, widać na niej lekki nalot. Złożono zapytne do producenta. Brak możliwości rozwiązania sporu wywołane zmiana Kierownika Zaopatrzenia.
554	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-06-24	2024-08-09	\N	Poprawiony rysunek
555	1	Wprowadzenie zmian do dokumentacji technologicznej.	2024-06-25	2024-09-02	\N	poprawiono 
556	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem	2024-06-30	2024-06-30	\N	praca ciągła
557	1	Detale transportowane podczas 2 zmiany, brak odpowiedniego nadzoru przez  Mistrza. Należy uczulić i przeszkolić pracowników oraz Mistrzów/ Zakup osłonek do tłoczysk na śr fi 50	2024-06-07	2024-07-01	\N	przeszkolono /osłonki zakupiono 01/07/24
558	1	Dodanie odpowiedniego dopisku do dokumentacji technologicznej- dot. mierzenia tłoczysk przed spawaniem. Uczulenie/ szkolenie pracowników. Większy nadzór przez Mistrzów.	2024-06-24	2024-06-26	\N	Szkolenie odbyło się 28.05.242 25.06.24 Wprowadzono dopisek do dokumenatcji. Najistotniejszym działaniem w tym zakresie jest nadzór Mistrza. 
559	1	Zbadanie sprawy	2024-06-24	2024-06-20	\N	Pracownik źle zamocował odkówki, nie zauważył problemu. Należy przeszkolić pracownika
560	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem. Jedna sztuka została odratowana.	2024-06-30	2024-06-30	\N	praca ciągła
561	1	Sztuki miały wymiar 289 (0-0,2) +0,03 do +0,1. Naddatk poza tolerancja został zebrany poprzez szlifowanie. W tym wypadku brakowało doświadczonego pracownika- proces wciskania tłoka wymaga doświadczenia. Zalecane stworzenie "sztywnego" narzęcia do wciskania tłoka- bez tulejek, które się rozlególowują i wpływają na posów. Dodatkowo należy złożyć zamówienie na wymagane przyrządy pomiarowe, których brakuje na Hartowni. Zaleca się również dostarczenie pistoletu na sprężone powietrze do przedmuchiwania tłoczysk- zdarzają się wióry, ktore mogą wylecieć w przyrządzie.	2024-06-28	2024-06-24	\N	24.06.24 2 pistolety są już na stanie. 26.06.24 Technologia podejmie kroki do stworzenia dedytkowanych narżedzi. Do niniejszego tłoka, "sztywne: narzędzie jest stworzone. Zamówienie na narzędzia w trakcie
562	1	Dokonanie dokładnej analizy problemu, wprowadzenie zmian do dokumentacji technologicznej. Badania przy kolejnej serii.	2024-07-20	\N	\N	Zmienieć rysunki, wkrętke pogłębić o 0,5 mm
563	1	Podjęcie działań zmierzających do skrócenia czasu oczekiwania pomiędzy wykonaniem operacji szlifowania a chromowaniem. Szlifowanie 28.05-chrom 04.06.	2024-06-30	2024-06-30	\N	praca ciągła
564	1	stworzenie karty pomiarowej	2024-06-28	2024-05-26	\N	Karta wprowadzona
565	1	Wcześniej przyszła reklamacja na te detale/niezgodność od odbiorcy. Zbadanie sprawy. 24.06.24 Sprawdzenieczy są na stanie sprawdziany tłokowe h9 (ew. stworzenie) Karta Kontrolna	2024-06-28	2024-08-09	\N	Rysunki mają zaznaczone wymiary "znaczki w trojkątach", które należy zmierzyć. Rysunek jest w Auto Ckdzied
566	1	Wprowadzenie zmian do dokumentacji, zmiana przyrząd.	2024-06-28	2024-08-11	\N	Będzie zmiana uszczelek na tłoku.
567	1	Trudny, problematyczny detal. Sytuacja często się powtarza. Zalecane stworzenie przyrządu do sprawdzenia szczelności spoin na produkcji przed wysłaniem na montaż.	2024-06-28	2024-07-20	\N	07.20.24 stworzno noey przyrząd, czkemay na produkcje oby wykonać testy
568	1	Ucho na gotowo/ Wiercenie i roztaczanie otworu fi 23 H7 w uchwycie 3 szczękowym	2024-06-28	2024-06-10	\N	Wprowadzono zaminy
569	1	10 szt warunkowo dopuszczonychWprowadzenie zmian do dokumentacji- naddatki jak do Ros Rocy	2024-07-10	2024-06-27	\N	Wprowadzono zmianę średnicy pod szlifowanie
570	1	Sprawdzenie osłonek	2024-07-25	2024-06-21	\N	Wprowadzono osłonki do spawania przyłączy
571	1	Wprowadzenie zmian do dokumentacji	2024-07-10	2024-07-05	\N	Wpisano odpowiednie tresci do opisówki
572	1	Wprowadzenie karty pomiarowej	2024-07-10	2024-07-07	\N	Karta została wprowadzona
574	1	Niedbale wykonane spawanie na automatach, bez używania tulejek ochronnych i preparatu antyodpryskowego. Zbadanie sprawy. 25.06.24 Korpus spawany "na oko" Bazą do spawania jest powierzchnia palonego ucha (nierówności). Spawane w tzw "kielichu"- Zalecane wprowadzenie ryski na rurze i korpusie.	2024-07-10	2024-09-05	\N	Tulejki ochronne sa używane, wzmorzona kontrola przez Mistrzów. Na rzie korzysta się z wersji spawalnej. Technologia czeka na produkcję aby wprowadzić odkuwki z ryskami
575	1	Wprowadzenie zmian do dokumentacji	2024-07-10	2024-09-02	\N	wprowadzono zmiany
576	1	Błąd pracownika, szkolenie (7/56 w serii)	2024-06-30	2024-06-26	\N	Szkolenie się odbyło 
577	1	Wprowadzenie zmian do dokumentacji	2024-07-10	2024-08-12	\N	wprowadzono zmiany
578	1	Stworzenie osłonek na gwint	2024-07-10	2024-08-19	\N	Wprowadzono zaślepkę M14x1,5 (króciec CJ2G-25/2.03)
579	1	Zakup 3 latarek	2024-07-15	2024-07-01	\N	zakupiono
580	1	Dostarczenie brakujących materiałów	2024-07-10	2024-07-01	\N	stworzono stanowisko z folią 
581	1	Należy wprowadzić zmiany do rysunków, aby uniknąć w przyszłości podobnych pomyłek	2024-07-11	2024-06-26	\N	wprowadzono modyfikację (rzut korpusu) na rysunku
582	1	Wprowadzenie zmian do dokumentacji	2024-06-30	2024-06-26	\N	Wprowadzono zmiany
583	1	Faymonville. Zmienić konstrukcję dławnicy	2024-08-08	2024-08-01	\N	Wprowadzono zmiany
584	1	Detale dopuszczone warunkowo. Brak odbioru 1 sztuki!!! Wprowadzić karte pomiarową.	2024-07-15	2024-07-05	\N	Wprowadzono kartę pomiarową
585	1	Wprowadzenie zmian do dokumentacji	2024-06-30	2024-06-26	\N	Wprowadzono zmiany
586	1	Wprowadzenie zmian do dokumentacji	2024-06-30	2024-06-27	\N	Wprowadzono zmiany
587	1	Wprowadzenie zmian do dokumentacji	2024-06-30	2024-06-26	\N	Wprowadzono zmiany
588	1	Wzmożona kontrola i szkolenie pracowników	2024-07-15	2024-07-15	\N	praca ciągła
589	1	Wprowadzenie zmian do dokumentacji	2024-06-30	2024-06-27	\N	Wprowadzono zmiany
590	1	Wprowadzenie zmian do dokumentacji. Poprawienie rysunku bądź opisówki	2024-07-14	2024-07-05	\N	Wprowadzono zmiany
591	1	Wprowadzenie zmian do dokumentacji. Należy zastanowić się nad tolerancjami przy wymiarze	2024-07-15	2024-07-01	\N	Wprowadzono zmiany
592	1	Wprowadzenie zmian do dokumentacji	2024-07-15	2024-07-01	\N	Wprowadzono zmiany
593	1	Zmienić dostawcę króćca CJ2D-C2-50/1.01-1 	2024-07-08	2024-07-05	\N	Weryfikacja i zmiana dostawcy króćća.
594	1	Stworzenie systemu nadzoru nad czystościa na malarni. Wymiana łańcuchów	2025-02-28	\N	\N	Przeniesione na początek 2025. 15.01.25 Prace mają trwać do końca lutego. 25.02.25 Zakończenie prac przesunięto na 18.02.25. Kolejno przesunięto na koniec kwietnia.
595	1	Materiał przeznaczyć na tłoki	2024-07-08	2024-07-08	\N	Wprowadzono odpowiednie dyspozycje
596	1	Toczenie odbylo się w połowie maja, zmiany wprowadzono w połowie czerwca 2024. 	2024-07-01	2024-07-01	\N	W przyszłości należy większą uwagę przyłozyć do kontroli pozostałych detali w momencie wprowadzania kart zmian.
597	1	Zbadanie sprawy. Wprowadzednie zmian do dokumentacji. 	2024-07-15	2024-09-08	\N	09.08.24 zalecane mycie króćców i przyłączy
598	1	Wprowadzednie zmian do dokumentacji	2024-07-22	2024-08-02	\N	Poprawa rysunku
599	1	Zbadanie sprawy	2024-07-22	2024-07-22	\N	nie do wyjasnienia
600	1	W operacji wiercenia nr 15 dopisać "zamocować detal w przyrządzie grubością ucha od góry". Wskazana byłaby tez uwaga na rysunkach.	2024-07-22	2024-07-18	\N	dopisano uwage w technologii
601	1	Problem nie do wyjaśnienia	2024-07-15	2024-07-15	\N	Problem nie do wyjasnienia
602	1	Dokładniejsze sprwdzanie powierzchni po wytrawianiu	2024-07-22	2024-07-22	\N	praca ciągła
603	1	Stworzenie odpowiednich osłonek	2024-07-15	2024-07-15	\N	Osłonki zostały wprowadzone
604	1	Stworzenie nowego procesu (ucho na gotowo)	2024-07-20	2024-07-17	\N	Proces zmieniono
605	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-08-15	2024-08-01	\N	wprowadzono zmiany do dokumentacji technologicznej
606	1	Zwiększona kontrola spawacza, dorobienie osłonek.	2024-08-15	2024-09-08	\N	osłonki dorobiono
607	1	Problem nie do wyjaśnienia	2024-07-15	2024-07-15	\N	Problem nie do wyjasnienia
608	1	Wprowadzenie zmian do zasad przekazywania Kart Zmian. Niewłaściwe zarządzanie zmianą.	2024-08-15	2024-08-15	\N	Instrukcja napisana
609	1	Stworzenie grupy badawczej, która przeanalizuje problem 	2024-08-15	2024-08-12	\N	Przprowadzenie wstępnej analizy
610	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-08-15	2024-08-01	\N	wprowadzono zmiany do dokumentacji technologicznej
611	1	Konstruktor po zauważeniu problemu związanego z brakiem wszytskich wymiarów na rysunkach, nie dostarczył zaktualizowanej dokumentacji na Produkcję. Należy porozmawiać z Konstruktorami w celu koordynacji przekazywania informacji pomiędzy działem Technologiczno- Konstrukcyjnym a Produkcją.	2024-08-30	2024-08-09	\N	Uczulenie i przeszkolenie konstruktorów
612	1	analiza problemu	2024-08-12	2024-08-12	\N	Przprowadzenie wstępnej analizy
613	1	analiza problemu	2024-08-30	2024-08-12	\N	Przprowadzenie wstępnej analizy
614	1	analiza problemu	2024-08-30	2024-08-12	\N	Przprowadzenie wstępnej analizy
615	1	Zmiana planu sprzedaży	2024-08-05	2024-08-05	\N	praca ciągła
616	1	Zmiana planu sprzedaży	2024-08-05	2024-08-05	\N	praca ciągła
617	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-08-05	2024-07-29	\N	wprowadzono zmiany do dokumentacji technologicznej
618	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-08-30	2024-08-09	\N	wprowadzono zmiany do dokumentacji technologicznej
619	1	Analiza problemu. 19.08.24 rozwiązanie sprawy przekazane w rę ce kierownika Radosława Szczęsnego.	2024-08-30	2024-08-24	\N	Odbyło się szkolenie wszytskich  pracowników malarni w dniu 23.08.24
620	1	analiza problemu/ stworzenie Karty kontrolnej do obudowę	2024-08-19	2024-08-14	\N	12.08.24 Operatorzy Juszkiewicz i Maniecki wykonali 245 szt na zleceniu 50641170. Tuleja posiada 15 wymiarów, należy oznaczyć wymiary krytyczne. Wprowadzono kartę kontrplną 14.08.24
621	1	analiza problemu	2024-09-16	2024-09-30	\N	Operator został przeszkolony 0..08.24. OD działu PP 12.08.24: Dział TTK miał znaleźć narzędzie do obróbki kanałka. Frez nie obrabia kanałków. Należy poprawić program (błęd). PUMA 1307. 30/09.24 Wg technologii program jest właściwy, problem po stronie operatora
622	1	Szkolenie pracwoników	2024-08-26	2024-08-30	\N	Pracownik już nie pracuuje
623	1	Napisanie WPS lub dodanie operacji honowania	2024-09-16	2024-11-25	\N	wps napisane
624	1	analiza problemu	2024-08-30	2024-08-30	\N	Wprowadzniee inf do technologi odnośnie obniżania mateiału na tłoczyka fi 22,2 i 20,2, dodtakowo ryr CN-S26 i CN-S36, bdź korzystanie z gotowego materiału.
625	1	analiza problemu	2024-08-30	2024-08-31	\N	Wprowadzniee inf do technologi odnośnie obniżania mateiału na tłoczyka fi 22,2 i 20,2, dodtakowo ryr CN-S26 i CN-S36, bdź korzystanie z gotowego materiału.
626	1	analiza problemu	2024-08-30	2024-09-01	\N	Wprowadzniee inf do technologi odnośnie obniżania mateiału na tłoczyka fi 22,2 i 20,2, dodtakowo ryr CN-S26 i CN-S36, bdź korzystanie z gotowego materiału.
627	1	analiza problemu	2024-08-30	2024-09-02	\N	Wprowadzniee inf do technologi odnośnie obniżania mateiału na tłoczyka fi 22,2 i 20,2, dodtakowo ryr CN-S26 i CN-S36, bdź korzystanie z gotowego materiału.
628	1	analiza problemu	2024-08-30	2024-08-30	\N	Wprowadzniee inf do technologi odnośnie obniżania mateiału na tłoczyka fi 22,2 i 20,2, dodtakowo ryr CN-S26 i CN-S36, bdź korzystanie z gotowego materiału.
629	1	Wymagane zwiększenie nadzoru nad montażem oraz uczulenie pracowników.	2024-08-26	2024-08-14	\N	Przeprowadzono szkolenie pracownika w dniiu 14.08.24
630	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-09-16	2024-08-26	\N	wprowadzenie zmian do dokumentacji
631	1	Poprawienie dokumentacji technologicznej oraz wporwdzenie instrukcji przekazywania kart zmian 	2024-09-16	2024-08-27	\N	wprowadzenie zmian do dokumentacji
632	1	Analiza problemu	2024-09-16	2024-09-16	\N	szkolenie pracowników, błąd ludzki
633	1	Analiza problemu	2024-09-16	2024-09-17	\N	szkolenie pracowników, błąd ludzki
634	1	Analiza problemu	2024-09-02	2024-09-16	\N	dorobienie osłonek przez dział TTK
635	1	Błąd pracownika, stworzenie karty pomiarowej	2024-09-03	2024-09-30	\N	Dział technologi nie zrobił Karty Kontrolnej, uważa, że jest to niezasadne. Widać tu jedynie brak pomiaru i skupienia pracownika
636	1	Analiza problemu	2024-09-04	2024-08-26	\N	operator pomylił zlecenia i zabral do dalszych operacji nieumyte nurniki
637	1	Szkolenie pracwoników	2024-09-05	2024-08-27	\N	Operacje wykonał pracownik, który już nie pracuje
638	1	Szkolenie pracwoników, dodanie uwag do dokumentacji technoloficznej, stworzenie kart standaryzacji pracy	2024-09-30	2024-09-05	\N	stworzono karty
639	1	stworzenie karty standaryzacji pracy	2024-09-30	2024-09-05	\N	stworzono karty
640	1	Stworzenie karty kontrolnej	2024-09-30	2024-09-30	\N	według technologii karta jest niezasana. Ewidentny błąd pracownika
641	1	Poprawa dokumentacji technologicznej	2024-08-30	2024-08-28	\N	dokonano zmian w dokumentacji
642	1	Poprawa dokumentacji technologicznej	2024-08-30	2024-08-28	\N	dokonano zmian w dokumentacji
643	1	Pierwsza seria wprowadzona po zmianach. Kolejna seria będzie dokładniej badana.	2024-08-30	2024-08-28	\N	zamknięcie problemu po analizie danych
644	1	Wprowadzedzie zmian do dokumentacji tłoczysk odnośnie obniżenia materiału (fi 22,2). Dodatkowo przeanalizowac należy di 20,2, oraz cylindry CN-S260i CN-S36. 	2024-09-23	2024-09-15	\N	Detala sa wykonywane z gotowego materiału. Wprowadzono zmiany o obniżeniu materiału 28.01.2025
645	1	stworzenie karty standaryzacji pracy	2024-09-23	2024-09-05	\N	stworzono karty
646	1	Uszkodzenia mechaniczne są niemożliwe do zdiagnozowania. Prawdopodobnie detale wypadły z palet. Należy stworzyć narzędzie do spawania w celu eliminacji odprysków. 	2024-09-30	2024-10-07	\N	dodano nowe lampy
647	1	Modernizacja oswietlenia przy stanowisku obróbki. Zaprojektowanie narządzia do spawania. Zmiana konstrukcji tłoka (tłok na gotowo?)	2024-09-30	2024-10-08	\N	dodano nowe lampy
648	1	Modernizacja oswietlenia przy stanowisku obróbki. Szlifierka kątowa, narzędzie do fazowania otworu (kamienna kulka?)	2024-09-30	2024-11-04	\N	16.09.24 rozpoczęto modernizację oświetlenia. 04.11.24 Ukończono modernizację. Zmieniono rozmieszczenie i dodano nowe żródła oświetlenia.
649	1	Wada materiału (krzywy, nierówny), należało go prostować. 	2024-09-30	2024-09-09	\N	Problem do dalszej analizy
650	1	Analiza problemu, potencjalne zmiany technologiczne	2024-09-30	2024-10-07	\N	wprowadzono zaślepki
651	1	Pomylono detale- do dalszych operacji użyto nieobrobionych sztuk. Znakowanie markerem obrobionych detali.	2024-09-30	2024-09-16	\N	zaczęto znakować detale
652	1	Szkolenie pracowników	2024-09-30	2024-09-20	\N	pracowniky już nie pracują
653	1	Szkolenie pracowników	2024-09-30	2024-09-21	\N	pracowniky już nie pracują
654	1	Różna średnica rur	2024-09-30	2024-09-09	\N	Problem do dalszej analizy
655	1	Analiza problemu, potencjalne zmiany technologiczne, wykonanie poglębienia	2024-09-30	2024-10-07	\N	dorobiono zaślepki
656	1	Wykonanie zmian technologicznych	2024-09-30	2024-09-23	\N	zmiany wpowadzono
657	1	Błąd pracownika	2024-09-16	2024-09-16	\N	Sprawa do monitorowania, niemożliwa do rozwiązania
658	1	Analiza dokumentacji technologicznej, dotyczaća ewentualnego wporwadzenia/ zmiany inf. odnośnie kalamitek. Sprawdzenie obróbki	2024-10-07	2024-09-20	\N	Przeprowadzono szkolenie pracowików przez kierownika Działu Kontroli Jakości
659	1	Opracowanie i wykonanie pryzm na CENTRA w celu obróbki jednocześnie kilku detali w jednym cyklu. Propozycja zaczęcia od detalu CNS36-70/2.00	2024-10-07	\N	\N	20.11.24 w dalszym ciągu trwają próby i badania 28.01.2025 nie ma pracownika do frezowania. 30.04.2025 Produkcja nie ma pracownika, chce przełozyć na koniec maja.
660	1	Analiza problemu. Wprowadze nie ewentualnych faz na korpusie i nurniku	2024-10-07	2024-10-24	\N	wprowadzono fazę 45 stopni na tulei cylindra
661	1	Wprowadzenie działań korygujących, naprawa okna	2024-10-07	2024-09-30	\N	okna zostały naprawione
662	1	Konserwan nałozono dzień wcześniej. Podczas 1 zmiany nie zauwazono korozji, wyszła dopiero podczas 2 zmiany	2024-09-23	2024-09-23	\N	Sytuacja nie do wyjaśnienia
663	1	Wprowadzenie instrukcji KZ	2024-10-07	2024-09-20	\N	wprowadzono
664	1	Analiza problemu. Zaprojektowanie osłonek cienkościennych.	2024-10-07	2024-10-21	\N	Osłonki zostały zaprojektowane, produkcja dostosowała je do własnych potrzeb
665	1	Wprowadzenie instrukcji KZ	2024-10-07	2024-09-20	\N	wprowadzono
666	1	Wprowadzenie zmian do dokumentacji technologicznej. Zmiana fazy na 20 stopni	2024-10-07	2024-10-07	\N	Fazy były już wprowadzone.
667	1	Szkolenie pracowników	2024-10-07	2024-09-24	\N	Szkolenie z zakresu bezwzględnego sprawdzania otworów po wierceniu i fazowaniu cofką. 
668	1	Analiza problemu i wprowadzenie odpowiednich zmian do dokumentacji technologicznej	2024-10-21	2024-10-07	\N	wprowadzono zmiany technologiczne
669	1	Analiza sytuacji	2024-09-30	2024-09-30	\N	Wymiana chłodziwa w szlifierce (było zanieczyszczone)
670	1	Seryjna produkcja tłoków uniemozliwia zdiagnozowanie proglemu. Karta kontrolna występuje.	2024-09-30	2024-09-30	\N	Sytuacja nie do wyjaśnienia
671	1	Pracowicy nie użyli zaślepek, jest ich zbyt mała ilość. Należy dorobić zaślepki.	2024-10-21	2024-10-07	\N	zaślepki dorobiono
672	1	Zrobić zmiany w specyfikacji technologicznej. Na rys. złożeniowym uwzględnić otwór w uchu dla ułatwienia kontroli. Zamieścić informacje o śrubie.	2024-10-21	2024-10-07	\N	wprowadzono zmiany technologiczne
673	1	Wprowadzenie zmian do dokumentacji	2024-09-30	2024-09-30	\N	zmiany wprowadzono
674	1	Wprowadzenie zmian do dokumentacji	2024-10-21	\N	\N	do 30.12.24
675	1	Wprowadzenie zmian do dokumentacji	2024-10-30	2024-10-08	\N	Zbyt gruba blacha, problemy z wypaleniem otworu wg T. Rakowski
676	1	Zamówienie kilku sztuk plandek ze sciągaczem na palety 800x1200	2024-10-30	\N	\N	30.10.2024 Zamówiono za duże plandeki. 20.12.2024 Zaopatrzenie nie może znaleźć odpowiednich plandek.
677	1	Wprowadzenie zmian do dokumentacji technologicznej	2024-10-10	2024-10-03	\N	zmiany wprowadzono
678	1	Zamawianie rur w lepszej klasie jakości	2024-11-30	2024-11-19	\N	W chwili obecnej, ze względu na Hydrotor, nie ma możliwości zamawiania materiału u innych dostawców.
679	1	Analiza sytuacji	2024-10-07	2024-10-07	\N	Po przeanalizowaniu wielu wariantów, niestey nie można ustalić przyczyny powstania uszkodzeń.
680	1	Pouczenie pracowników	2024-10-07	2024-10-07	\N	\N
681	1	Analiza sytuacji	2024-11-04	\N	\N	Wprowadzane na bieżaco
682	1	Analiza sytuacji	2024-11-04	2024-10-21	\N	pomylono rysunki
683	1	Analiza sytuacji	2024-11-04	2024-12-10	\N	poprawiono przyrząd
684	1	Analiza sytuacji	2024-11-04	2024-11-02	\N	Nurniki skorodowały na malarni, woda zebrała się wewnątrz nurnika i nie wyparowała tworząc korozję. Nurniki zostały wyczyszczone szczotką, wyciorem. 20.11.24 Stworzenie instrukcji dotyczącej zabezpieczenia wnętrza detali podczas operacji na malarni. Otwory należy zabezpieczać gąbką.
685	1	Analiza sytuacji	2024-11-04	2024-11-02	\N	Nurniki skorodowały na malarni, woda zebrała się wewnątrz nurnika i nie wyparowała tworząc korozję. Nurniki zostały wyczyszczone szczotką, wyciorem. 20.11.24 Stworzenie instrukcji dotyczącej zabezpieczenia wnętrza detali podczas operacji na malarni. Otwory należy zabezpieczać gąbką.
686	1	Stworzenie instrukcji obróbki detali na stanowiskach obróbki ręcznej	2024-11-04	2024-10-30	\N	Instrukcja została stworzona
687	1	analiza sytuacji	2024-11-04	2024-11-20	\N	następiło przesunięcie sondy. Należy dopilnować rutynowych kontroli
688	1	Stworzenie instrukcji obróbki detali na stanowiskach obróbki ręcznej	2024-11-04	2024-10-30	\N	Instrukcja została stworzona
689	1	Wymyślić i opisać sposón uniwersalnego postępowania z tłoczyskami podczas transportu wewnętrznego	2024-11-04	2024-10-30	\N	Instrukcja została stworzona
690	1	Analiza sytuacji 	2024-10-23	2024-10-23	\N	wada materiału
691	1	Zmiany w dokumentacji- podtoczenie na tulei prowadzącej	2024-11-10	\N	\N	KZ?
692	1	Krzywy materiał	2024-10-23	2024-10-23	\N	wada materiału
693	1	Zmiany w dokumentacji- korzystanie z płytki promieniowej? 	2024-11-10	2024-12-10	\N	20.11.24 Trwają badania zasadności konieczności użycia spirali, oraz skorzytsania z modernizacji cofki.10.12.2024 płytki promieniowe są na bieżąco wprowadzane
694	1	Wprowadzenie zian konstrukcyjnych	2024-12-20	2025-01-07	\N	KZ 3/2025
695	1	Wprowadzenie zmian do dokumentacji	2024-11-10	2024-11-09	\N	zmiany wprowadzono
696	1	Zwiększyć naddatek	2024-10-23	2024-10-23	\N	Zwiększono naddatek
697	1	Wprowadzenie zmian do dokumentacji	2024-11-10	\N	\N	W trakcie 29.01.2025
698	1	Dodanie opracji szczepiania z przyrządem	2024-11-10	\N	\N	\N
699	1	Nie wykonywanie wszytskich operacji, należy wykonywac operację odprężania. Wprowadzenie zmian technologicznych	2024-11-18	2025-11-30	\N	Wprowadzono bez karty zmian!!!!!!!!
700	1	Wprowadzenie zmian do dokumentacji	2024-10-24	2024-10-24	\N	Zmiany wprowadzono
701	1	Wprowadzenie zmian do dokumentacji	2024-10-25	2024-10-25	\N	Zmiany wprowadzono
702	1	Wprowadzenie osłonek na odpowietrzniki i przyłącza	2024-11-18	2024-11-05	\N	Osłonki sa, nie zostały pobrane przez pracowników
703	1	Wproiwadzenie zmian technologicznych	2024-11-18	2024-11-18	\N	Mistrzowie zobowiązani do bardziej szczegółowej kontroli 
704	1	Stosowanie zaslepek do króćców	2024-10-28	2024-10-28	\N	Mistrzowie pobrali zaślepki
705	1	Wprowadzenie we wszystkich siłownikach, faz na spawanie na tulei cylindra 20 stopni. Spawanie 1 warstwy CO2, 2 warstwy mieszanką. Pozwoli to ograniczyć odpryski. Stworzenie osłonek.	2024-11-25	\N	\N	sukcesywnie wprowadzane
706	1	Wprowadzenie zmian do dokumentacji	2024-11-25	2025-02-25	\N	Zmiany wprowadzono
707	1	Analiza sytuacji. Ewidentny błąd pracownika, prawdopodobnie nie kontrolował wymiarów	2024-11-12	2024-11-12	\N	Upomnienie, szkolenie pracowwników
708	1	Krzywy, graniasty materiał	2024-11-04	2024-11-04	\N	Obecnie brak możliwości zmiany dostawcy i materiału
709	1	Analiza sytuacji	2024-12-02	2024-12-02	\N	Pracownik pomiesza tłoczyska i materiały
710	1	Wprowadzenie zmian do dokumentacji konstrukcyjno-technologicznej.	2024-12-02	\N	\N	KZ 69/24 nie zatwierdzona
711	1	Powtarzający się problem. Analiza sytuacji, dojście do sedna problemu.	2024-12-02	2024-12-02	\N	Nie można usunąć technolicznie, pracownicy zobowiązani do usuwania wiórów ręcznie
712	1	Analiza sytuacji, wprowadzenie zmian technologicznech, użycie nowych płytek do obróbki gwintu?	2024-12-02	2025-03-05	\N	Wprowadzono zmiany- płytka jednoostrzowa i inny sposób wyjścia z gwintu (dodatkowa obróbka)
713	1	Sprawdzenie zasadności i efektywności stosowania obróbki  grubszego materiału i większej ilości przejść.	2024-11-25	\N	\N	\N
714	1	Sprawdzanie tłoczysk i nurników z rur na stanowisku KJ po szlifowaniu, przed chromem	2024-11-25	2024-11-20	\N	Nurniki sprawdzane przy KJ.
715	1	Wprowadzenie zmian do dokumentacji konstrukcyjno-technologicznej.	2024-12-02	2025-02-12	\N	Wprowadzono bez karty zmian!!!!!!!!
716	1	Powtarzający się problem. Analiza sytuacji, dojście do sedna problemu.	2024-12-02	2024-12-02	\N	Nie można usunąć technolicznie, pracownicy zobowiązani do usuwania wiórów ręcznie
717	1	Wprowadzenie zmian do dokumentacji 	2024-12-20	2025-01-28	\N	Dodano uwagę o stępieniu krawędzi
718	1	Dorobienie osłonek do spawania	2024-12-21	2024-12-20	\N	osłonki dorobiono
719	1	Analiza problemu (dodanie operacji planowania, użycie większego frezu?) Inne narzędzie?obrobka?	2024-12-22	2024-01-05	\N	Technologia uważa iż należy robić dokładą obróbkę
720	1	Wprowadzić zmiany w dokumentacji. Dodać na wszytskich rysunkach przyłączy informację" usunąć ostre krawędzie"	2024-12-23	2024-12-10	\N	Informacja dodana wcześniej
721	1	Nierównomierne dziury. Dzlifowano i chormowano 19 listopada, tego samego dnia. Zalecana wymiana kąpieli	2024-12-30	2024-12-20	\N	Kąpiel na galwanizerni została wymieniona
722	1	Przeprowadzenie szkolenia pracowników w zakresie istotności dokładnego ogratowania otwórów. Cofka	2024-12-09	2024-12-06	\N	Szkolenie się odbyło. 06-12-2024. Technolog uważa nie nie można uwzględnić cofki
723	1	Szkolenie pracowników (najdokładniejsze kręcenie ręczne)	2024-11-26	2024-11-26	\N	\N
724	1	Analiza problemu, identyfikacja przyczyn i znalezieni esobosoby rozwiązania problemu dotycz acego nieogratowanych detali. Wprowadzenie planu kontroli pracowników. 	2024-12-20	2025-01-01	\N	Zmieniono system płac
725	1	Testowanie osłonek gwintów z rury. Po myciu należy dokładnie osuszyć gwinty i nie pakować ich od razu w folię.	2024-12-06	2024-12-06	\N	 Po myciu należy dokładnie osuszyć gwinty i nie pakować ich od razu w folię.
726	1	Wprowadzenie zmian do dokumentacji, dodanie operacji i czasów.	2024-12-20	2024-11-26	\N	Wprowadzono zmiany
727	1	Analiza sytuacji	2024-12-20	2025-01-05	\N	zmieniono proces
728	1	Analiza sytuacji. (Dlaczego osłonki nie są używane?)	2024-12-20	\N	\N	Szkolenie pracowników
729	1	Stworzenie odpowiedniego przyrządu do wciskania (analiza i zmiana oprzyrządowania pod nową prasę)	2024-12-20	\N	\N	Według technologów temat był jednorazowym incydentem, spowodowanym wciskaniem tulejek przez osadzonego.
731	1	Słabo umyte, opłukane tulejki, nie zostały wystarczająco wysuszone. Zapakowano w folię, pod którą się "spociły" analiza sytuacji	2024-12-20	2024-12-10	\N	Poinstruowanie pracowników
732	1	Wymiana kąpieli	2024-12-30	2024-12-20	\N	Kąpiel na galwanizerni została wymieniona
733	1	Według produkcji łozyska wciskano ostatnio po próbach z uwagi na niedostępność łożysk. TTK ma znaleźć rozwiązanie	2025-01-15	\N	\N	na bierząco, powoli zmiana na wciskanie tulejek na produkcji.
734	1	Detale do poprawy. Pracownicy sprawdzający pierwsza sztukę przy kontroli jakości, mają wypełniać kartę konrtolną z wymiarami, które chcą sprawdzić	2024-12-23	2024-12-22	\N	Wprowadzenie nowego systemu wynagrodzeń  od nowego roku
735	1	Analiza przycyzn problemu- czy za niezgodność odpowiada problem z maszyną czy mateiałem.	2024-12-23	2024-12-10	\N	Pracownik dobrał nieodpowiednie parametry
736	1	Analiza przyczyn problemu- czy za niezgodność odpowiada problem z maszyną czy mateiałem.	2024-12-23	2024-12-10	\N	Pracownik dobrał nieodpowiednie parametry
737	1	Wdrożenie działań odnośnie stosowania zaślepek transportowych i do spawania	2024-12-16	2024-12-10	\N	Wdrożono
738	1	Ustalenie miejsca powstania niezgodności i zapobiegnięcie ponownemu wystapieniu	2024-12-16	2024-12-10	\N	Miejsce nie do ustalenia
739	1	Analiza sytuacji	2024-12-16	2024-12-22	\N	Wprowadzenie nowego systemu wynagrodzeń  od nowego roku
740	1	Pracownik się zwolnił	2024-09-12	2024-09-12	\N	\N
741	1	Wptrowadzenie zmian do dokumentacji. Zastanowić się nad zmiana promienia gięcia. Zastosowanie mieszanki zamiast dwutlenku.	2025-01-16	2025-01-16	\N	Niewłasciwie korpusy z kooperacji, dokładniejsza kontrola
742	1	Tłoczyska nie zostały umyte na czas. Przejrzeć stan osłonek.	2024-12-23	2025-04-04	\N	Stworzono nowe osłonki i przekazano do użytkowania.
743	1	Sprawdzenie procesu przed chromowaniem, przede wszystkim toczenia. Sprawdzenie przy kolejnej serii.	2025-01-16	2025-01-28	\N	Technolog sprawdził proces, uważa za poprawny. Do kontroli przy kolejnej serii.
744	1	Dostosowanie narzędzi. Wymagane wypełnienie kart kontrolnych. Wprowadzenie "zeszytu" dla praconików na zgłaszane problemy, niezgodności.	2025-02-25	2025-02-25	\N	Wprowadzono "zeszyt".
745	1	wprowadzić odpowiednie procedury odnośnie kontroli przekazwywanych detali z montazu na produkcję (niebeskie karty?)	2024-12-30	2024-12-20	\N	Niebieska karta obowiązkowa przy przekazywaniu detali
746	1	Zmienić króciec (są przetopy). M22x1,5. Negocjacje z klientem.	2025-01-30	2025-01-29	\N	Klient się nie zgadza na inny króciec. Większa kontrola po spawaniu
747	1	Wprowadzić drugi oring/smarowanie tulei smarem miedzianym zamiast oleju/zmiana dokumentacji	2025-01-30	\N	\N	jest smarowane smarem miedzianym, sprawdzane
748	1	Sprawdzenie programów.\nSprawdzenie czy pracowncy wykonują operacje prawidłowo.\nDlaczego pracownicy nie zwracają uwagi na niewłaściwą obróbkę?	2025-02-25	\N	\N	Prace nad usuwaniem zadziorów na bierząco. T Rakowski 28.01.2025
749	1	Sprawdzić na produkcji czy wszytskie tuleje są robione w nowym programie/ Ewentualna zmiana i analiza sytuacji.	2025-01-30	2025-01-25	\N	Poprawione programy dot. wejścia i wyjścia z gwintów.
750	1	Instrukcja postępowania? Osoba nadzorująca?	2025-03-05	\N	\N	\N
751	1	Analiza- czy można inaczej ustawić proces lub kanałek montażowy?	2025-01-31	2025-01-31	\N	20.01.2025 wprowadzone mycie wszytskich detali przed spawaniem. TTK nie widzi możliwości wprowadzenia kanałka, brak miejsca.
752	1	Stosowanie zaślepek. \nZabezpieczenie detali przed odpryskami. Przeglądanie, mycie przed spawaniem.	2025-01-20	2025-01-17	\N	Detale są myte przed spawaniem/Zaślepki są stosowane/ Pracownicy upomnieni
753	1	Skomplikoane korpusy z gniazdami na zawory należy obrabiać i myć przed spawaniem.	2025-01-30	2025-01-28	\N	Detale będą obrabiane i myte. Jest operacja obróbki, wg Technologów, jest wystarczająca
754	1	Pouczenie, skuteczne zarzdzanie pracownikami	2025-01-10	2025-01-10	\N	Pracownik po mimo kilkukrotnego zwracaina uwagi, nieroztropnie rozwoził detale. Ostatecznie został odsunięty na inne stanowisko.
755	1	Zmiana konstrukcyjna w obudowie i korpusie dotycząca otworu w sondach i korpusie. Zabezpieczenia przyłączy do transportu	2025-02-20	\N	\N	Trwają próby 28.01.2025 (Produkcja nie chce wpuścić na maszynę)
756	1	Skuteczniejsze zarządzanie pracownikami i organizacja pracy	2025-02-15	2025-01-28	\N	Wprowadzane na bieżaco 28.01.2025. Poprawiono we wszytskich siłownikach.
757	1	Poinformowanie pracowników. Zmiana technologii w zakresie wykonania denka na gotowo i spawania do ucha.	2025-02-16	2025-01-18	\N	01.17.2025 Pracownik został obciążony, poinformowany. TTK nie zgadza się na zmianę technologi, ponieważ pozostałe podobne detale robimy w ten sam sposób. Do ewentualnego rozwarzenia przy potencjalnym kolejnym problemie.
758	1	Kanałek spiralny powinien być obrabiany płytką promieniową. Zmiana technologii.	2025-02-17	2025-01-28	\N	W trakcie 28.01.2025. Zmiana programu i narzędzia.
759	1	Poinformowanie pracowników. 	2025-01-20	2025-01-17	\N	01.17.2025 Pracownik został obciążony, poinformowany
760	1	Wprowadzenie zmian technologicznych. Wkładka teflonowa/ większe łożysko.	2025-02-15	2025-02-15	\N	W trakcie wykonywania narzedzi 28.01.2025. Wprowadzono wkładkę teflonową.
761	1	Podjęcie działań mających na celu lepszą organizacje pracy dla KJ	2025-02-01	2025-02-01	\N	Odciążenie Kontroli Jakości od działań wykonywanych w ramach pomocy produkcji.
762	1	Usuwanie odprysków/Wydłużenie osłon/Stosowanie innych/ NOWE OSLONY- dłuższe	2025-02-15	2025-02-15	\N	TTK uważa, że osłony są dostępne, należy wymagać kontroli przez Mistrzów
763	1	Zawsze kalibrować/zmiana technologii/uwaga	2025-02-16	2025-02-15	\N	20.01.2025 Pracownicy zostali poinformowani o konsekwencjach i związanych z tym obciążeniami. TTK uważa, że nie ma możliwości wprowadzenia zmian.
764	1	Zmiana rysunku, wprowadzenie informacji dotyczącej szerokości spoiny. 	2025-02-15	2025-01-28	\N	Wprowadzono informację o spoinie
765	1	Zidentyfikowano pracownika odpowiedzialnego za braki	2025-01-20	2025-01-20	\N	Pracownik został zwolniony
766	1	Zidentyfikowano pracownika odpowiedzialnego za braki	2025-01-20	2025-01-20	\N	Pracownik został zwolniony
767	1	Zidentyfikowano pracownika odpowiedzialnego za braki	2025-01-20	2025-01-20	\N	Pracownik został zwolniony
768	1	Wprowadzenie zmian do dokumenatcji technologicznej- cofa, obróbka ucha/ wykonywanie dokładnej obróbki	2025-02-15	2025-01-28	\N	Dopisanie obróbki do opercji.
769	1	Dokładniejsze zarzadzanie planowaniem produkcji	2025-01-22	2025-01-22	\N	\N
770	1	Przygotowanie listy potrzebnych narzędzi. 	2025-02-15	\N	\N	Pracownicy zostali poinformowani. Trwa poszukiwanie narzedzia pneumatycznego. 20.02.25
771	1	Przygotowanie listy potrzebnych narzędzi. 	2025-02-15	\N	\N	Pracownicy zostali poinformowani. Trwa poszukiwanie narzedzia pneumatycznego. 20.02.25
772	1	Odpowiednie zarządzanie pracownikami.	2025-01-27	2025-01-24	\N	Pracownicy zostali poinformowani, zmniejszono premię.
773	1	Wymóg wypełniania kart kontrolnych.	2025-01-27	2025-01-24	\N	Pracownicy zostali poinformowani, zmniejszono premię.
774	1	Przestrzeganie instrukcji kart zmian.	2025-01-23	2025-01-23	\N	Praca ciągła
775	1	Nowy przyrząd? Stworzenie listy potrzebnego przyrządowania i realizacja na podstawie listy.	2025-02-25	2025-04-04	\N	Wykonanie nowego oprzyrządowania
776	1	Wprowadzić płytkę promieniową/przestrzegać wykonywania operacji/ wprowadzić zmianę- spawanie korpusu przed króćcami	2025-02-15	2025-02-05	\N	W trakcie 28.01.2025. Wprowadzenie nowego narzędzia i zmiany w programie
777	1	Instrukcja postępowania? Osoba nadzorująca?	2025-03-05	2025-04-02	\N	Wprowadzono zmiany w rysunkach
778	1	Cechowaie według wymagań klienta, według siłowników typowych, katalogowych. Brak informacji od marketingu.	2025-03-05	\N	\N	\N
779	1	Osłonki do spawania przyłącza?	2025-03-05	\N	\N	\N
780	1	Poprawa technologii	2025-03-05	\N	\N	\N
781	1	Gwintowanie od środka?	2025-03-05	\N	\N	01.03.2025 Należy poprawić wejścia i wyjścia z gwintu- wprowadzenie płytki jednostrzowej/ wycowafnie dwuostrzowej. Programy????
782	1	WPS/ Pogłębienie na rurce/ Inne dojście do rurki/ Przyrząd do sprawdzania szczelności/ Szkolenia spawalnicze	2025-03-05	2025-04-14	\N	Sprawdzenie przyrządu przy kolejnej serii CJ-S274-40
783	1	Zmiana tolerancji/zmiana technologi	2025-02-16	2025-02-05	\N	Wprowadzono zmiany dotyczące wykonania i narzędzi
784	1	Sprawdzenie czasów	2025-02-15	2025-02-05	\N	Wprowadzono korekty
785	1	Zatwierdzenie KZ	2025-02-06	\N	\N	\N
786	1	Zakładanie wcześniej segerów/ odpowiednie zagniatamnie/ Zapewnienie odpowiedniego oprzyrządowania. Zmiana organizacji pracy na produkcji.	2025-02-15	2025-03-15	\N	02.05.25 Przejrzano oprzyrządowanie, wprowadzono zmiany.
787	1	Wciskanie tulejek na produkcji	2025-02-04	2025-02-04	\N	Wprowadzenie odpowiednich działań
788	1	Większy nadzór mistrzów.	2025-03-10	2025-03-10	\N	Wyieniono pracownika
789	1	Nowy przyrząd? (268-40? Był przyrząd)	2025-03-10	2025-03-10	\N	Pracownik został ukarany 
790	1	Karta zmian, instruktarz konstruktorów.	2025-03-10	\N	\N	\N
791	1	Poprawa programu	2025-03-10	2025-03-10	\N	Zaminy wprowadzono
792	1	Uczulenie pracowników	2025-03-10	2025-04-02	\N	Zaminy wprowadzono
793	1	Wprowadzenie zmian 	2025-03-10	2025-03-05	\N	Zaminy wprowadzono
794	1	Ponowne zapoznanie się z instrukcją dot. Postępowania z materiałem żeliwnym. Udostępnienie instrukcji Mistrzom. Podpisywanie pod nowymi/ uzanymi za istotne instrukcjami przez wszytskie zainteresowane osoby, aby zatwierdziły zapoznanie się z obowiązującymi normami.	2025-03-10	2025-03-14	\N	Ponowne zapoznanie się z instrukcją dot. Postępowania z materiałem żeliwnym. Udostępnienie instrukcji Mistrzom. Podpisywanie pod nowymi/ uzanymi za istotne instrukcjami przez wszytskie zainteresowane osoby, aby zatwierdziły zapoznanie się z obowiązującymi normami.
795	1	Sprawdzić proces, oprzyrządowanie, próba z zaślepką	2025-03-10	2025-04-04	\N	stworzenie nowych hakow do chromowania
796	1	Brak przyrządu? Operacji Szczepiania? Rozbierzność widać dopiero po spawaniu króćca.	2025-03-10	\N	\N	\N
797	1	Zmiana programu? Dodanie operacji polerowania, poprawa spirali	2025-03-10	2025-03-05	\N	Zaminy wprowadzono
798	1	Dodac drugi orign? Kontrolować temperaturę? Smarowanie smarem miedzianym?	2025-03-10	2025-03-01	\N	Ręczne wkręcanie zaślepek transportowych 
799	1	Zwiększona kontrola stanu technologii przed wprowadzeniem	2025-03-10	2025-03-10	\N	\N
800	1	Zgłoszenie reklamacji do klienta. Wymaganie działań  naprawczych	2025-03-10	\N	\N	\N
801	1	Osłonki?	2025-03-10	\N	\N	\N
802	1	Wprowadzenie obowiązkowej operacji szlifowania po kazdym wypaleniu?	2025-03-15	2025-03-10	\N	zgłaszane i uzupełniane na bierząco
803	1	Nowy przyrząd/ Powiększenie frezowania	2025-02-25	2025-02-20	\N	Zmieniono wymiary otworu fi 20 (+1+0,5) na fi 22
804	1	Sprawne narzędzie do zagniatania łożysk/ Brak pomijania operacji/ dokładna kontrola w razie przestawienia operacji/ właściwe zarządzanie dopuszczeniami i przekazywanie informacji.	2025-03-15	\N	\N	\N
805	1	Wykonanie dodatkowych osłon?	2025-03-15	\N	\N	\N
806	1	Zastosowanie konserwantu? / Monitorowanie, prowadzenie zapisów, kontrola stężenia. Udpstępnienie instrukcji.	2025-03-15	2025-03-15	\N	Wprowadzono liste dotyczącą sprawdzania poziomu chłodziwa
807	1	Spis ilości niewłaśiwego materiału. Obliczenie pracochłonności do reklamacji.	2025-03-15	2025-03-15	\N	Systematyczne tworzenie listy niewłaściwych materiałów i zgłaszanie reklamacji do dostawcy.
808	1	Spis ilości niewłaśiwego materiału. Obliczenie pracochłonności do reklamacji.	2025-03-15	2025-03-15	\N	Systematyczne tworzenie listy niewłaściwych materiałów i zgłaszanie reklamacji do dostawcy.
809	1	Wzmorzyć nadzor	2025-03-15	2025-03-15	\N	Pouczenie mistrzów
810	1	Wzmorzyć nadzor	2025-03-15	2025-03-15	\N	Pouczenie mistrzów
811	1	Zmiana technologi chromowania	2025-03-15	2025-02-26	\N	Wykonaywanie detali z gotowego prętu chromowanego.
812	1	Polerowanie przez zastosowanie nowej tasmy	2025-03-15	2025-03-15	\N	Polerowanie przez zastosowanie nowej tasmy
813	1	Stworzenie stanowiska do przycinania rurek na montażu. Przygotowanie informacji odnośnie wymaganej długości rurki, w zalezności od danego zaworu.\nCo ze stanowiskiem ? TTK stworzyło ale zostało rozmontowane	2025-03-15	\N	\N	ZEBRANIE
814	1	Monitorowanie, prowadzenie zapisów, kontrola stężenia. Udpstępnienie instrukcji.	2025-03-15	2025-03-15	\N	Wprowadzono liste dotyczącą sprawdzania poziomu chłodziwa
815	1	Monitorowanie, prowadzenie zapisów, kontrola stężenia. Udpstępnienie instrukcji.	2025-03-15	2025-03-15	\N	Wprowadzono liste dotyczącą sprawdzania poziomu chłodziwa
816	1	Zmiana wymiaru połpierścieni	2025-03-16	2025-03-10	\N	wprowadzono zmiany
817	1	Zakup kredek do sprawdzania temperatury	2025-04-30	\N	\N	\N
818	1	Wprowadzenie zmian technologicznych	2025-04-30	\N	\N	Wladek
819	1	Wprowadzenie zmian technologicznych	2025-04-30	\N	\N	14.03.2025 Dział TTK podaje, iż problem wynika ze zmiany usczelki w tulei prowadzącej, z czym nie zgadza się Montaż. Do weryfikacji przy kolejnym montażu. 30.03.25 zmieniono uszczelkę na tłoku, trwają badania.
820	1	Wprowadzenie zmian technologicznych	2025-04-30	\N	\N	\N
821	1	Wprowadzenie zmian technologicznych	2025-04-30	\N	\N	\N
822	1	Wprowadzenie wymiaru ograniczającego spoinę	2025-04-30	\N	\N	????????????
823	1	Wzmorzony nadzór Mistrza i Kontrolera	2025-03-15	2025-03-15	\N	Wzmorzony nadzór Mistrza i Kontrolera. ROZLICZANIE
824	1	Zatrudnienie odpowiednich pracowników	2025-03-16	2025-03-16	\N	Zatrudnienie wstępnie 1 dodatkowego pracownika.
825	1	Analiza sytuacji, zatrudnienie dodatkowego pracownika.	2025-04-30	\N	\N	Pouczenie pracowników
826	1	Rozważenie mozliwości zamawiaqnia gotowego materiału.	2025-04-30	2025-03-24	\N	Systematyczne tworzenie listy niewłaściwych materiałów i zgłaszanie reklamacji do dostawcy.
827	1	Wprowadzenie zmian technologicznych	2025-04-30	\N	\N	\N
828	1	kosnserwowac	2025-04-30	\N	\N	Pouczenie pracowników, nakaz stosowania konserwantu
829	1	Pracownik został ukarany zmniejszeniem premii.	2025-04-30	2025-04-05	\N	Pracownik został ukarany zmniejszeniem premii.
830	1	Pracownik został ukarany zmniejszeniem premii.	2025-04-30	2025-04-05	\N	Pracownik został ukarany zmniejszeniem premii.
831	1	Analiza, znalezienie sposobu. 	2025-04-30	\N	\N	\N
832	1	Analiza sytuacji.	2025-04-30	\N	\N	Zabranie premi????
833	1	Sprawdzanie przetopu na nowym narzedziu do szczelności spoin	2025-04-30	\N	\N	Sprawdzanie przetopu na nowym narzedziu do szczelności spoin
834	1	Operacja fazowania na korpusie? Na centrach?	2025-04-30	\N	\N	\N
835	1	Instrukcja!	2025-04-30	\N	\N	\N
836	1	Wprowadzenie zmian do dokumentacji, zapewnienie procesu bądż zmiana wymagań.	\N	\N	\N	\N
\.


--
-- TOC entry 5022 (class 0 OID 19117)
-- Dependencies: 225
-- Data for Name: dzialanie_opis_problemu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dzialanie_opis_problemu (dzialanie_id, opis_problemu_id) FROM stdin;
23	35
24	61
24	62
25	61
25	62
26	63
27	64
28	65
29	66
30	67
31	69
32	70
33	72
33	73
33	74
34	72
34	73
34	74
35	72
35	73
35	74
36	76
37	77
38	78
39	79
63	35
68	61
69	62
70	63
71	64
72	65
73	66
74	67
75	69
76	70
77	72
77	73
77	74
78	72
78	73
78	74
79	72
79	73
79	74
80	76
81	78
82	79
111	101
112	103
114	115
116	88
132	85
132	95
132	96
132	114
133	85
133	95
133	96
133	114
135	85
135	95
135	96
135	114
142	116
144	85
144	95
144	96
144	114
148	121
158	105
160	90
161	107
164	98
165	118
170	117
179	94
180	94
181	108
182	108
184	109
185	120
191	81
191	82
191	83
191	85
191	87
191	89
191	91
191	92
191	93
191	95
191	96
191	97
191	99
191	100
191	102
191	104
191	106
191	110
191	111
191	112
191	113
191	114
191	119
192	86
193	86
194	84
195	84
196	84
226	103
229	88
231	87
231	88
238	102
239	102
240	102
242	99
243	99
243	102
244	85
244	95
244	96
244	114
245	85
245	95
245	96
245	114
246	85
246	95
246	96
246	101
246	114
247	85
247	95
247	96
247	101
247	114
248	85
248	95
248	96
248	101
248	114
249	85
249	95
249	96
249	101
249	114
250	82
250	115
251	82
252	82
253	116
254	116
255	116
256	116
258	85
258	95
258	96
258	114
259	85
259	95
259	96
259	114
262	121
269	105
269	121
272	105
273	90
274	90
275	107
281	100
283	110
283	112
283	118
284	117
287	81
287	91
294	94
295	108
296	108
298	109
299	120
301	97
301	111
302	113
306	86
307	83
307	85
307	86
307	89
307	92
307	93
307	95
307	96
307	98
307	104
307	105
307	106
307	113
307	114
307	119
307	121
310	84
311	160
312	154
312	206
312	226
312	231
312	324
312	337
312	417
312	490
312	499
313	361
314	233
314	302
314	313
315	154
315	206
315	226
315	231
315	324
315	337
315	417
315	490
315	499
316	154
316	206
316	226
316	231
316	324
316	337
316	417
316	490
316	499
317	201
318	260
319	154
319	206
319	226
319	231
319	324
319	337
319	417
319	490
319	499
320	457
321	213
322	154
322	206
322	226
322	231
322	324
322	337
322	417
322	490
322	499
323	154
323	206
323	226
323	231
323	324
323	337
323	417
323	490
323	499
324	509
325	529
326	194
327	154
327	206
327	226
327	231
327	324
327	337
327	417
327	490
327	499
328	197
329	398
330	301
330	369
331	301
331	369
332	301
332	369
333	154
333	206
333	226
333	231
333	324
333	337
333	417
333	490
333	499
334	273
335	389
336	154
336	206
336	226
336	231
336	324
336	337
336	417
336	490
336	499
337	154
337	206
337	226
337	231
337	324
337	337
337	417
337	490
337	499
338	129
339	174
340	214
340	420
341	465
342	432
343	397
344	233
344	302
344	313
345	233
345	302
345	313
346	234
347	133
347	419
347	425
348	133
348	419
348	425
349	356
350	133
350	419
350	425
352	275
353	152
354	163
355	310
356	409
357	294
358	176
359	449
360	295
361	465
362	465
363	411
364	334
365	251
367	278
368	202
369	528
370	245
370	363
371	238
372	214
372	420
373	372
374	191
374	258
375	191
375	258
376	135
377	147
378	172
379	309
379	442
380	309
380	442
381	223
383	245
383	363
384	540
385	237
386	534
387	353
388	336
388	469
389	336
389	469
390	127
391	406
392	236
392	500
393	269
394	132
395	236
395	500
396	204
397	161
398	431
747	543
748	499
749	361
750	233
750	313
751	417
752	226
753	201
754	260
755	206
756	457
757	213
758	231
759	154
760	529
761	194
762	337
763	197
764	398
765	301
765	369
766	301
766	369
767	301
767	369
768	324
769	273
770	490
771	490
772	129
773	174
774	420
776	432
777	233
777	313
778	302
779	234
780	419
781	133
782	356
783	425
785	275
786	152
787	163
788	310
789	409
790	294
791	176
792	449
793	295
794	465
796	411
797	334
798	251
800	278
801	202
802	528
803	363
804	238
805	214
806	372
807	191
807	258
808	191
808	258
809	193
809	249
810	193
810	249
811	135
812	147
813	172
814	309
814	442
815	309
815	442
816	170
817	223
818	245
818	444
819	245
819	444
820	245
820	444
821	245
821	444
823	540
824	534
825	353
826	336
827	245
827	444
828	406
829	132
829	500
830	132
830	500
832	236
833	403
834	204
835	161
836	431
\.


--
-- TOC entry 5023 (class 0 OID 19120)
-- Dependencies: 226
-- Data for Name: dzialanie_pracownik; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dzialanie_pracownik (dzialanie_id, pracownik_id) FROM stdin;
1	8
2	7
3	7
4	7
5	7
6	7
7	7
8	3
8	4
9	3
10	5
10	8
11	3
12	3
13	3
14	3
15	3
16	5
17	3
17	5
18	3
19	3
20	3
20	4
21	4
22	4
23	3
24	3
25	3
26	8
27	7
28	8
29	3
30	8
31	3
32	1
32	3
33	8
34	8
35	8
36	8
37	1
38	4
39	1
39	2
40	1
40	3
41	8
42	7
43	7
44	8
45	7
46	7
46	8
47	7
48	3
48	4
48	8
49	3
50	3
50	5
50	8
51	3
52	3
53	3
54	3
55	3
56	5
57	7
58	7
59	3
59	7
59	8
60	3
60	4
60	8
61	4
62	4
63	7
64	9
65	9
66	4
66	7
67	3
67	7
68	3
69	3
70	3
70	8
71	7
72	8
73	3
73	8
74	8
75	3
76	1
76	3
80	8
81	3
82	2
83	3
84	3
85	3
86	3
87	3
88	3
89	3
90	3
91	3
92	3
93	3
94	3
95	3
96	3
97	3
98	3
99	3
100	3
101	3
102	3
103	3
104	8
105	8
106	8
107	8
108	8
109	8
110	8
111	8
112	3
113	3
114	3
115	8
116	8
117	8
118	8
119	8
120	8
121	8
122	8
123	8
124	8
125	8
126	8
127	8
128	8
129	8
130	8
131	8
132	8
133	8
134	8
135	8
136	8
137	8
138	8
139	3
140	3
141	3
142	3
143	8
144	8
145	8
146	3
147	3
148	3
149	3
150	3
151	3
152	3
153	3
154	3
155	3
156	3
157	3
158	3
159	8
160	8
161	8
162	3
163	3
164	3
165	8
166	8
167	8
168	8
169	8
170	8
171	8
172	8
173	8
174	8
175	8
176	8
177	8
179	8
181	8
182	8
183	7
184	7
185	7
186	8
187	8
188	8
189	8
190	8
191	8
192	8
193	8
194	8
195	8
196	8
197	7
198	7
199	7
200	7
201	7
202	3
203	3
204	3
205	3
206	3
207	3
208	3
209	3
210	3
211	3
212	8
213	8
214	8
215	8
216	8
217	8
218	7
219	7
220	7
221	7
222	7
223	7
224	8
225	8
226	7
230	3
231	3
234	3
235	3
236	3
237	3
238	7
239	7
240	3
242	3
244	3
245	8
246	7
247	7
248	7
249	8
251	3
252	3
253	7
254	3
255	3
256	8
258	3
259	3
261	3
262	3
267	3
268	3
269	3
270	3
271	3
272	3
273	9
274	7
275	3
279	7
282	7
283	7
284	3
286	3
287	3
288	7
291	7
292	7
293	7
294	7
295	8
296	8
297	7
298	7
299	7
301	7
302	3
306	8
308	8
309	8
310	8
399	1
400	1
401	1
404	3
404	8
404	15
404	16
405	7
416	23
417	16
418	16
419	7
420	17
421	7
423	17
424	17
425	7
426	17
427	7
428	7
429	23
430	7
432	7
433	8
434	7
436	20
437	20
438	20
440	15
441	15
442	7
443	7
444	7
445	7
446	1
447	7
448	23
449	16
453	7
454	8
455	7
456	7
457	7
458	7
459	7
460	7
461	7
465	23
466	7
467	16
468	21
472	23
475	8
477	15
478	8
479	7
480	7
481	7
483	14
484	7
486	7
489	3
489	8
489	15
489	16
491	7
492	7
493	22
494	7
495	7
496	20
497	20
498	23
499	21
502	15
503	15
504	7
506	7
507	5
510	3
511	19
512	7
513	7
514	7
515	7
516	7
517	7
518	16
519	15
520	7
521	7
524	7
527	7
528	7
529	7
530	23
531	7
534	7
535	7
537	7
539	7
540	7
542	7
543	5
544	7
545	5
547	7
548	7
549	7
550	5
551	5
552	7
553	3
553	8
553	15
553	16
554	7
555	7
556	5
559	3
559	8
559	15
559	16
560	5
563	5
564	7
566	7
567	7
568	7
569	7
570	22
571	7
572	7
575	7
576	23
577	7
578	7
581	7
582	7
583	7
584	7
585	7
586	7
587	7
588	3
589	7
590	7
591	7
592	7
593	9
595	9
596	7
598	7
599	3
599	8
599	15
599	16
600	7
602	19
603	7
604	7
605	7
608	8
610	7
611	7
612	3
613	3
614	3
617	7
618	7
621	3
622	23
623	7
624	3
625	3
626	3
627	3
628	3
629	3
630	7
631	7
632	23
633	23
634	23
636	23
637	23
639	8
640	7
641	7
642	7
643	7
644	7
645	8
650	7
652	22
652	23
653	22
653	23
655	7
656	7
660	7
661	1
663	8
665	8
666	7
667	22
667	23
668	7
669	3
669	7
669	8
671	7
672	7
673	7
674	7
675	7
676	9
677	7
678	9
679	3
679	7
679	8
680	3
681	3
681	7
681	8
682	3
682	7
682	8
683	3
683	7
683	8
684	3
684	7
684	8
685	3
685	7
685	8
687	23
691	7
693	7
694	7
695	7
697	7
698	7
699	7
700	7
701	7
702	7
703	7
705	7
706	7
707	23
708	9
709	3
709	7
709	8
710	7
712	7
714	23
715	7
717	7
718	7
719	7
720	7
721	3
723	18
725	7
726	7
727	3
727	7
727	8
729	7
730	22
730	23
731	2
732	3
733	7
735	8
736	8
737	3
738	3
739	3
739	7
739	8
741	7
742	2
745	3
746	7
749	7
750	7
751	7
752	3
754	3
755	7
756	7
758	7
759	3
760	7
761	8
765	3
766	3
767	3
769	5
770	3
771	3
772	3
773	3
774	3
777	7
778	7
784	7
785	7
787	3
788	3
789	3
790	7
791	7
792	7
793	7
797	7
799	7
800	9
802	7
803	7
809	3
810	3
811	7
812	3
816	7
818	7
819	7
820	7
821	7
822	7
823	3
824	3
825	9
827	7
829	3
830	3
831	3
832	3
833	3
835	3
836	7
\.


--
-- TOC entry 5024 (class 0 OID 19123)
-- Dependencies: 227
-- Data for Name: firma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.firma (id, nazwa, kod, oznaczenie_klienta) FROM stdin;
58	AMTR System	\N	\N
46	Zoller	\N	\N
72	J.A.Becker&Sohne	\N	196002
80	Sipma	\N	0876-332-207
86	Zoeller Tech	\N	5812202978
79	Samasz	\N	0347.03.15.000 W
63	Cometto	\N	270201
69	Hako	\N	201966
64	Cynkomet	\N	\N
66	Gerd Bar	\N	1XX114687
48	Hydromega	\N	\N
82	Steel-Tech	\N	\N
81	Stal-Kom	\N	\N
68	Haco	\N	1007017H
2	ASSA ABLOY 	\N	\N
10	Peltrax	\N	\N
28	MEGA	\N	\N
76	PPHU Volant	\N	chwytak
61	CNH Kutno	\N	90453627
77	Rite-Hite	\N	GM005494
62	CNH Płock	\N	92161515
23	Gandhi	\N	\N
21	Leppiink	\N	\N
38	Parker	\N	\N
4	Gerd Bar 	\N	\N
18	Becker	\N	\N
6	Novoferm	\N	DS0120000V0700
24	Amazonen	\N	\N
7	Ulrich Rink	\N	\N
25	Zoeller	\N	\N
12	Struers	\N	2YC70001
26	Duvelsdorf	\N	\N
49	Precizo	\N	\N
15	Wood-Mizer	\N	711617
36	Agroland	\N	\N
20	Assa Abloy	\N	P1399197
47	Ponar	\N	\N
39	Akpil	\N	\N
14	Dautel	\N	88453
19	Maschio Gaspardo	\N	\N
16	Zakrem	\N	\N
9	Expom	\N	\N
44	AMTR	\N	\N
42	Kamag	\N	64340487
35	Unia	\N	2146140
34	MBS-Hydraulik	\N	\N
29	Agro-Masz	\N	\N
22	Faymonville	\N	\N
13	HACO	\N	\N
30	Volant	\N	\N
40	Leppink	\N	CIL040AG (rechts)
41	Goldhofer	\N	168188
8	Fricke	\N	\N
27	Agricola	\N	1.07.00.050
31	CNH	\N	\N
17	PHU Ramatech-Instal	\N	\N
37	Hydrotor	\N	174085102
3	BBG	\N	GA054
5	Hormann	\N	\N
32	Sulej	\N	\N
45	Bar	\N	\N
43	Metal-Fach	\N	\N
11	Auto-Moto	\N	\N
1	Aebi Schmidt	\N	1157075-7
33	Ros Roca	\N	S24100-2100-0116(1109159)
\.


--
-- TOC entry 5026 (class 0 OID 19127)
-- Dependencies: 229
-- Data for Name: opis_problemu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opis_problemu (id, opis, przyczyna_bezposrednia, status, miejsce_zatrzymania, miejsce_powstania, uwagi, kod_przyczyny, przyczyna_ogolna) FROM stdin;
1	Nieaktualna instrukcja funkcjonująca w dziale I-TBR-01 „Proces badania wyrobu”- należy uaktualnić i dostosować do bieżącej sytuacji w Przedsiębiorstwie, w zakresie podległości służbowej oraz sposobie realizacji projektów.	\N	w trakcie	\N	\N	\N	\N	\N
2	Brak zaktualizowanych instrukcji technologicznych	\N	w trakcie	\N	\N	\N	\N	\N
3	Liczne niezgodności związane z brakiem kompatybilności pomiędzy opisówkami i rysunkami (rozbieżności, aktualizacja tylko jednego z nich)	\N	w trakcie	\N	\N	\N	\N	\N
4	Niewłaściwe zarządzanie zmianą. Karty zmian wprowadzane na Produkcję bez całościowej zmiany dokumentacji technologicznej, prowadząc do chaosu i dezorganizacji na Produkcji.	\N	w trakcie	\N	\N	\N	\N	\N
5	Niewłaściwe zarządzanie zmianą. Karty zmian wprowadzane na Produkcję bez całościowej zmiany dokumentacji technologicznej, prowadząc do chaosu i dezorganizacji na Produkcji.	\N	w trakcie	\N	\N	\N	\N	\N
6	Brak archiwizowanej dokumentacji dotyczącej zlecenia wykonania projektu nowego wyrobu, wraz z pokwitowaniem przez Kierownika Działu Sprzedaży i Marketingu oraz Kierownika Działu Technologiczno- Konstrukcyjnego (Instrukcja I-TTK-01).	\N	w trakcie	\N	\N	\N	\N	\N
7	Brak archiwizacji zapisów wyników weryfikacji procesu projektowania (Instrukcja I-TTK-01).	\N	w trakcie	\N	\N	\N	\N	\N
8	Brak bieżącego raportowania o wykonaniu celów jakościowych (Punkt 2 Zarządzenia Zarządu z dnia 12.01.2024r).	\N	w trakcie	\N	\N	\N	\N	\N
9	Karty dopuszczenia jakościowego nie są każdorazowo wypełniane poprawnie. Często brakuje podpisu Mistrza, na którym spoczywa odpowiedzialność zatwierdzania detali oraz danych dotyczących ilości przekazywanych wyrobów (Instrukcja I-NJ-18 Kontrola dostaw wewnętrznych)	\N	w trakcie	\N	\N	\N	\N	\N
10	Brak przekazywania informacji zwrotnej do Działu Jakości dotyczącej wykonania naprawy reklamacji przez dział Produkcji (Instrukcja I-NJ-12 Postępowanie z reklamacjami zewnętrznymi)	\N	w trakcie	\N	\N	\N	\N	\N
11	Nie dokonywanie zapisów w przewodniku na temat realizacji wykonania rozkroju (Instrukcja I-PP-04/A Proces produkcji. Planowanie produkcji i rozkrój materiałów)	\N	w trakcie	\N	\N	\N	\N	\N
12	Wystawianie PW oraz zatwierdzanie Kart Dopuszczenia jakościowego na Galwanizerni, często realizowane jest przez Kontrolera Jakości z powodu braków kadrowych (Instrukcja I-PP-04/A Proces produkcji)	\N	w trakcie	\N	\N	\N	\N	\N
13	Proces malarni: niezachowana czystość i porządek, brak instrukcji obsługi na wszystkich urządzeniach, przechowywanie zbyt dużej ilości detali i materiałów (farb), zastawienie dróg i przejść. (Instrukcja I-PP-04/D Proces produkcji malowania siłowników hydraulicznych)	\N	w trakcie	\N	\N	\N	\N	\N
14	Produkcja korzysta z wyeksploatowanych narzędzi (9.1 Monitorowanie, pomiary, analiza i ocena, 8.5 Produkcja i dostarczanie usług)	\N	w trakcie	\N	\N	\N	\N	\N
15	Brak/nie wypełnianie karty pomiarowej przy przewodniku (Instrukcja I-PP-04/J Proces produkcji Stosowania kart pomiarowych)	\N	w trakcie	\N	\N	\N	\N	\N
16	Nie wypełnianie kart kontrolnych przez pracowników (9.1 Monitorowanie, pomiary, analiza i ocena)	\N	w trakcie	\N	\N	\N	\N	\N
17	Brak aktualnych zaktualizowanych zakresów obowiązków Mistrzów Produkcji- realizacja tłoków, tulei oraz prototypowni nie jest do nikogo przypisana (7.1 Zasoby, 7.2 kompetencje)	\N	w trakcie	\N	\N	\N	\N	\N
18	Zalecane stworzenie (wraz z TL, TTK, VPP, JK) instrukcji/zapisu/metodyki postępowania z detalami prototypowymi i wzorcami. Pozwoli to na usystematyzowanie działań oraz przypisanie osób nadzorujących proces. Obecnie, po przejściu na emeryturę dotychczasowego opiekuna procesu, nastąpił brak odpowiedniego nadzoru i realizacji. (8.1 Planowanie i nadzór nad działaniami operacyjnymi)	\N	w trakcie	\N	\N	\N	\N	\N
19	Zalecane stworzenie (wraz z TL, TTK, VPP, JK) instrukcji/zapisu/metodyki postępowania z detalami prototypowymi i wzorcami. Pozwoli to na usystematyzowanie działań oraz przypisanie osób nadzorujących proces. Obecnie, po przejściu na emeryturę dotychczasowego opiekuna procesu, nastąpił brak odpowiedniego nadzoru i realizacji. (8.1 Planowanie i nadzór nad działaniami operacyjnymi)	\N	w trakcie	\N	\N	\N	\N	\N
20	Brak bieżącego raportowania o wykonaniu celów jakościowych (Punkt 2 Zarządzenia Zarządu z dnia 12.01.2024r).	\N	w trakcie	\N	\N	\N	\N	\N
21	Opinie dotyczące możliwości konstrukcyjno-technologicznych nie są udokumentowane i podpisane przez dział TTK (I-HSM-01 Proces obsługi klienta. Przegląd umowy).	\N	w trakcie	\N	\N	\N	\N	\N
22	Analiza możliwości terminowych, dotycząca realizacji projektów, nie jest dokładnie przeprowadzana. Brak planu projektów z ustalonymi terminami realizacji, dokumentacji i podpisów osób odpowiedzialnych: TL, TTK, PP, HSM (I-HSM-01 Proces obsługi klienta. Przegląd umowy).	\N	w trakcie	\N	\N	\N	\N	\N
23	Brak skutecznej i systematycznej analizy ryzyka i szans- może skutkować utrudnieniami w identyfikacji zagrożeń, wcześniejszym przeciwdziałaniu, niewykorzystywaniu szans i niskiej odporności na zmiany	\N	w trakcie	\N	\N	\N	\N	\N
24	Brak bieżącego raportowania o wykonaniu celów jakościowych- brak nadzoru nad realizacją celów procesowych prowadzi do nieskutecznego zarządzania i brakiem kontroli nad działaniem procesów	\N	w trakcie	\N	\N	\N	\N	\N
25	Nieporządek panujący na magazynie stali- przeterminowane pasy transportowe, pozostałości foli, palety oraz przekładki i śmieci na regałach oraz polach składowania materiałów. Magazyn w nieuporządkowanym stanie stwarza potencjalne zagrożenie dla jakości przechowywanych materiałów i bezpieczeństwa pracowników.	\N	w trakcie	\N	\N	\N	\N	\N
26	Stan magazynu technicznego- sypiący się tynk ze ścian i sufitu, nierówne podłoże, brak możliwości sterowania wilgotnością, niedostateczne zabezpieczenie wszystkich detali (nie wszystkie zaślepki są w zamkniętych woreczkach/pojemnikach). Widoczne zaniedbania infrastrukturalne mogą wpływać na jakość przechowywanych produktów i bezpieczeństwo pracy	\N	w trakcie	\N	\N	\N	\N	\N
27	Brak sprawnej komunikacji pomiędzy działami- problemy wynikają z każdej ze stron. Zaopatrzenie nie zawsze jest informowane o zmianach wynikających z przesunięcia terminów produkcyjnych, natomiast zdarza się, iż na produkcje nie trafiają informacje o statusie dostępności produktów. Problemy dotyczą również wymiany informacji dotyczących wyrobów niezgodnych i reklamacji. Brak skutecznej komunikacji wpływa na jakość i skuteczność funkcjonowania Firmy	\N	w trakcie	\N	\N	\N	\N	\N
28	Brak aktualizacji instrukcji- Nieaktualne (odnośnie podległości służbowej, przestrzegania sposobu postępowania, wykorzystywanych dokumentów, stosowania Kart Dopuszczeń), nieprawidłowo zdefiniowane (brak identyfikacji wydania i podpisów) i przestarzałe	\N	w trakcie	\N	\N	\N	\N	\N
29	Nieaktualna lista detali przy strefie reklamacyjnej- Brak aktualizacji listy, co prowadzi do problemów z identyfikacją produktów reklamacyjnych	\N	w trakcie	\N	\N	\N	\N	\N
30	Nieskuteczne zarządzanie dostawami- znaczne opóźnienia w dostawach materiałowych, brak skutecznego monitorowania terminowości dostawców wpływa na opóźnienia w produkcji.	\N	w trakcie	\N	\N	\N	\N	\N
297	Ciasny gwint M95x2	\N	zakonczone	M	P	\N	\N	\N
31	Nieidentyfikowalny materiał- nie każdy detal na magazynie stali (zarówno wewnątrz jak i na zewnątrz hali) jest w pełni identyfikowalny (brakuje oznaczeń, identyfikatora dostawy). Brak oznakowania materiałów, co prowadzi do trudności w śledzeniu i zarządzaniu zapasami	\N	w trakcie	\N	\N	\N	\N	\N
32	Niewłaściwie przechowywany materiał- poza halą materiał jest przechowywany w sposób niewłaściwy. Stal składowana w niekontrolowanych warunkach jest narażona na korozję i uszkodzenia.	\N	w trakcie	\N	\N	\N	\N	\N
33	Niewłaściwe przekazywanie produktów z magazynu technicznego. Niezgodność dotyczy regału przy magazynie technicznym (detale pod zlecenia produkcyjne)- pracownicy pozostawiają niewykorzystane detale lub podpierają z innego zlecenia. Panuje tam nieporządek, transportowane produkty nie są zawsze właściwie zabezpieczone	\N	w trakcie	\N	\N	\N	\N	\N
34	Nieskuteczne zarządzanie reklamacjami- zaopatrzenie nie prowadzi rejestru reklamacji, które prowadzi do chaosu komunikacyjnego i informacyjnego (brak historii, wiedzy dotyczącej uprzednich reklamacji, możliwości śledzenia statusu).	\N	w trakcie	\N	\N	\N	\N	\N
36	Brak rozliczania kierownictwa z realizacji działań	\N	w trakcie	\N	\N	\N	\N	\N
37	Brak systemu egzekwowania realizacji działań korygujących i prewencyjnych	\N	w trakcie	\N	\N	\N	\N	\N
38	Nieefektywna komunikacja wewnętrzna i współpraca między działami	\N	w trakcie	\N	\N	\N	\N	\N
39	Audyt nowego/ potencjalnego dostawcy min 1 na miesiąc	\N	w trakcie	\N	\N	\N	\N	\N
40	Umowa jakościowa: zmienić treść (norma ISO 9001:2015 bądź inny system zarządzania- stworzy możliwość podpisania z innymi kooperantami)- podpisać min 5 i kolejne	\N	w trakcie	\N	\N	\N	\N	\N
41	Przedstaw min. 5 przykładów dokumentów PPAP od dostawców ( teraz więcej)	\N	w trakcie	\N	\N	\N	\N	\N
42	Udowodnić na jakiej podstawie REACH nie jest wymagany	\N	w trakcie	\N	\N	\N	\N	\N
43	Badanie detali spektrometrem? ( raz na miesiąc jeden produkt)	\N	w trakcie	\N	\N	\N	\N	\N
44	Raporty 8d od dostawców	\N	w trakcie	\N	\N	\N	\N	\N
45	Rejestr reklamacji	\N	w trakcie	\N	\N	\N	\N	\N
46	Rejest kooperacji	\N	w trakcie	\N	\N	\N	\N	\N
47	Upewnij się, że ustawiona maksymalna temperatura (25) i wilgotność (65) spełniają wymagania MSDS / warunków przechowywania producenta.\nKażdy materiał w magazynie musi mieć etykietę. 	\N	w trakcie	\N	\N	\N	\N	\N
48	Materiał, który wraca z produkcji, musi mieć etykietę, aby zapewnić możliwość śledzenia.\nZłom / materiał nieprodukcyjny należy usunąć / przechowywać oddzielnie.	\N	w trakcie	\N	\N	\N	\N	\N
49	Zdefiniuj wewnętrzny plan projektu z kamieniami milowymi, działaniami i osią czasu zgodnie z datami dostaw do klienta części prototypowych / początkowych wzorców / seryjnych.\nDokumentuj i zapisuj protokoły ze spotkań.\n1 wystarczy?	\N	w trakcie	\N	\N	\N	\N	\N
50	Tworzenie standardowej listy kontrolnej dla studium wykonalności na etapie zapytania ofertowego i dodatkowo do zwolnienia projektu do produkcji seryjnej. Lista kontrolna musi zostać potwierdzana przez wszystkie zaangażowane działy.	\N	w trakcie	\N	\N	\N	\N	\N
51	Wykonywać SPC w sposób systematyczny w celu usprawnienia procesów.\nUdokumentowane działania w związku z korzystaniem z SPC	\N	w trakcie	\N	\N	\N	\N	\N
52	Dodatkowo, do obecnej sytuacji przedstawionej w macierzy kompetencji, dodaj status docelowy, aby zobaczyć luki/wąskie gardła, opracuj plan szkoleniowy, biorąc pod uwagę status docelowy.	\N	w trakcie	\N	\N	\N	\N	\N
53	Zdefiniuj listę części zamiennych i min. stan magazynowy w oparciu o jasne kryteria.	\N	w trakcie	\N	\N	\N	\N	\N
54	Elektroniczna (może być Excel) lista całego stanu magazynowego części i stanów minimalnych. Przeprowadzenie inwentury mienia. Należy uwzględnić cały stan, nie tylko najnowszy.	\N	w trakcie	\N	\N	\N	\N	\N
55	Analiza awaryjności maszyn (prowadzenie statystyk- wydajność, awarie, przestoje, itp.)	\N	w trakcie	\N	\N	\N	\N	\N
56	Ulepsz analizę danych i wizualną prezentację w porównaniu z celami (wykresy) w celu dalszych ulepszeń.\nAnaliza pojemności jest ulepszona, przedstawiona na wykresach. \nPunkt do sprawdzenia na następnym spotkaniu przeglądowym.	\N	w trakcie	\N	\N	\N	\N	\N
57	Realizacja celów produkcyjnych (KPI)	\N	w trakcie	\N	\N	\N	\N	\N
58	W przypadku audytów wewnętrznych upewnij się, że plan działań jest wdrożony, a skuteczność potwierdzona.	\N	w trakcie	\N	\N	\N	\N	\N
59	Analiza FMEA zostanie rozszerzona o więcej ryzyk zgodnie z ryzykiem/możliwościami procesowymi i wymaganiami rysunkowymi.	\N	w trakcie	\N	\N	\N	\N	\N
60	Renowacja malarni	\N	w trakcie	\N	\N	\N	\N	\N
99	Cylindry mocno nieszczelne w okolicach fajki. Prawdopodobnie była poprawa spawania ponieważ uszczelnienia są stopione. 	Stopiony oring i pierścień oporowy. Siłowniki naprawione bez demontażu na przyłączu dławnicy.	w trakcie	\N	\N	\N	\N	\N
80	- Sprzątanie można poprawić\n- Pomimo wdrożenia 5S w niektórych obszarach, zaobserwowano bałagan w przestrzeni produkcyjnej w innych obszarach – np. malarni.\n- Firma powinna również wyeliminować składowanie wyrobów gotowych / materiałów na zewnątrz (aby w jak największym stopniu chronić produkt).	\N	w trakcie	\N	\N	\N	\N	\N
78	- Zamówienie klienta nie jest w pełni identyfikowalne w systemie\n- W trakcie audytu zaobserwowano, że zamówienie klienta WZ 98423 nie zostało zrealizowane, brakowało 46 części (ze 146) do realizacji zamówienia, a status zamówienia w systemie ERP to "ZWOLNIONE".\nNiezgodność wystąpiła na terenie magazynu wyrobów gotowych, gdzie przechowywanych detali (akurat do Struersa), nie było już na stanie magazynu (wcześniej sprzedane).	Absencja pracowników malarnii, wyroby gotowe lecz ostatnia paleta nie była spakowana i przekazana na magazyn	w trakcie	\N	\N	\N	\N	\N
89	Siłownik nieszczelny na spoinie GA474	Niewykrycie przecieku.	w trakcie	\N	\N	\N	\N	\N
79	- Niektóre chemikalia nie są odpowiednio przechowywane lub oznakowane, słaba identyfikacja lub brak\njej wcale, patrz zdjęcia.\n- Niektóre beczki są przechowywane bez "zbiornika zbiorczego" pod nimi.\n- Karty\ncharakterystyki nie są zgodne z najnowszą aktualizacją przepisów.	W trakcie audytu przedstawiono wyciągi z kart charakterystyk substancji chemicznych sporządzone na podstawie aktualnie obowiązujących kart. Nieaktualna była wyłącznie podstawa prawna na podstawie której sporządza się karty.	w trakcie	\N	\N	\N	\N	\N
122	Brak zgodności ze specyfikacją. Otwarcie zlecenia- 13.08.24 KZ 13.08.24. Zlecenie otwarte przed wprowadzeniem zmian. Po zmianie konstrukcyjnej wydano stare tłoczyska.	\N	zakonczone	M	P	\N	\N	\N
123	Brak szczelności, dziury.	\N	zakonczone	P	G	\N	\N	\N
124	Niezgodność wymiarowa pogłębienia, na rysunku fi 18, a w opisie fi 20 (+0,2)	\N	zakonczone	P	P	\N	\N	\N
126	Wymiar fi 62 (0;-0,013) jest 61,960/61,970. DOPUSZCZONE WARUNKOWO.	\N	zakonczone	P	P	\N	\N	\N
128	Brak obróbki kanałka frezowanego 6+10 pod zabezpieczenie (pozostał wiór)	\N	zakonczone	M	P	\N	\N	\N
130	Pomylono ucho, zostało przyspawane z nieodpowiednim tłoczyskiem (podobne do CJ-S131-110/2.00)	\N	zakonczone	M	P	\N	\N	\N
131	Cylinder CJ-S277-70/35/600 A źle dobrana tuleja prowadząca. Wymagana dodatkowa przeróbka na tokarce uniwersalnej.	\N	zakonczone	P	P	\N	\N	\N
134	Brak materiałów zabezpieczających detale chromowane po myjce. Brak stanowiska z folia zabezpieczającą	\N	zakonczone	M	P	\N	\N	\N
136	Pogłębienie pod tulejkę pośrednią i przyłącza wykonane po niewłaściwej stronie (powinno być od grubości ucha 15 mm).	\N	zakonczone	P	P	\N	\N	\N
137	Nie można zmontować cylindrów. Ciasny otwór fi 63H9 w obudowie w miejscu spawania listwy zębatej. Wymiar w miejscu spoiny fi 63,8-62,9	\N	zakonczone	M	P	\N	\N	\N
138	Zmienić tolerancję na 15 (+0,15;+0,05) i fi 35,9 (-0,05;-0,1). Pasek ciasno chodzi w obudowie.	\N	zakonczone	P	P	\N	\N	\N
139	Zadzior w otworze przyłącza fi 6 obudowy	\N	zakonczone	M	P	\N	\N	\N
140	Brak stosowania osłonek przez spawaczy.	\N	zakonczone	P	P	\N	\N	\N
141	Nieusunięte odpryski z otworu fi 21	\N	zakonczone	M	P	\N	\N	\N
142	niedopuszczalna chropowatośc Ra=1,036	\N	zakonczone	P	G	\N	\N	\N
143	Otwor M10x1 przesunięty w osi, różnica na ściankach do 5 mm	\N	zakonczone	M	P	\N	\N	\N
144	brak chropowatości	\N	zakonczone	P	G	\N	\N	\N
145	Nie możlna zamontować cylindra. Owal w otworze obudowy do 0,4 mm w granicach fi 110,85- fi111,25	\N	zakonczone	M	P	\N	\N	\N
146	podczas kalibrowania ciasnego gwintu M24x1,5 pracownik uszkodził fazę gwintownikiem	\N	zakonczone	P	P	\N	\N	\N
148	Dziury w chromie, brak szczelności, cała paleta.	\N	w trakcie	P	P	\N	\N	\N
149	za mało gwintu m12x1,5 na wykonanie podtoczenia fi 12,5 (nurnik wkręca się na 14 mm)	\N	zakonczone	\N	P	\N	\N	\N
150	Uszkodzenia mechaniczne (obicia) na powierzchni nurnika	\N	zakonczone	M	P	\N	\N	\N
151	Uszkodzenia mechaniczne (obite). Odpryski po spawaniu w otworze ucha.	\N	zakonczone	M	P	\N	\N	\N
153	wymia r po gięciu ucha 66 (+1,0/-0,5) a jest 62 mm. Sztuk nie można poprawić ponieważ wymiar 62 jest w dolnej częcie ucha przy promieniach gięcia	\N	zakonczone	P	P	\N	\N	\N
155	Brak przetopu w grani. Spawanie niezgodne z technologią, ucha do odcięcia	\N	zakonczone	P	P	\N	\N	\N
156	W operacji spawalniczej nr 15 brak informacji naq temat przyrządu SPX-10680	\N	zakonczone	P	P	\N	\N	\N
157	Tarka na powierzchni chromowanej	\N	zakonczone	M	G	\N	\N	\N
158	Ciasny gwint M36x2. Po kalibrowaniu bicie gwintu względem czoła tłoka do 4,5 mm	\N	zakonczone	M	P	\N	\N	\N
159	brak kresek ustawnych do spawania korpusu z rurą Automat (robot)	\N	zakonczone	P	P	\N	\N	\N
160	Spirala i dziury po szlifie, wykryte na galwanizerni przez chromem	Graniasty, krzywy materiał	\N	M	G	\N	\N	\N
162	Za duzy nadlew lica, blędna technologia spawania zastosowana przez spawacza	\N	zakonczone	P	P	\N	\N	\N
164	Pod kodem nie ma zapisanego rysunku tylko opisówka	\N	zakonczone	M	P	\N	\N	\N
165	Utrzymanie wiercenia otworu fi 41H7 w osi korpusu ucha  powoduje znaczne różnice w grubości ścianki płetwy w promieniu R35. Zalecana dod operacja na trasowaniu głównej osi przed frezowaniem wybrania w pletwie 45x125	\N	zakonczone	P	P	\N	\N	\N
166	Wiór spiralny w przyłączu. Ciasny i luźny gwint po 1 szt	\N	zakonczone	M	P	\N	\N	\N
167	Nie zachowany wymiar otworu fi 20 H12. Wykonano na fi 19,8. Wcześniej była reklamacja 2 szt z CNH. Sztuki sprawdzono i pobrano z rozdzielni.	\N	zakonczone	M	P	\N	\N	\N
168	Nie kalibrowany gwint G 1/8. Odpryski po spawaniu na gwincie i zabieleniu.	\N	zakonczone	M	P	\N	\N	\N
169	Korozja na uchu tłoczyska po chromowaniu	\N	zakonczone	M	P	\N	\N	\N
171	brak współosiowatości otworu fi 35 na tulejkach (różnica na grubości ścianki do 2,5 mm)	\N	zakonczone	P	P	\N	\N	\N
173	Brak zaślepek do spawania w korpusie. Odpryski po spawaniu na zabieleniu i na gwincie G 1/8	\N	zakonczone	\N	\N	\N	\N	\N
175	niestabilny proces wiercenia fi 10 z pogłębieniem fi 28	\N	zakonczone	P	P	\N	\N	\N
177	Podczas dokręcania nakrętki do tłoka podkładka, która jest między tłokiem a nakrętką wystaje ponad średnicę tłoka i rysuje otwór fi 63H9 w obudowie.	\N	w trakcie	M	P	\N	\N	\N
178	Na detalachpo polerowaniu wyszła duża korozja, pomimo użycia konserwanu po szlifowaniu dzień wcześniej	\N	zakonczone	P	P	\N	\N	\N
179	Uszkodzenie mechaniczne tłoczyska. Wykryte na stendzie- 5 szt. Odwrotnie przyspawany króciec, stożkiem do obudowy- 1 szt	\N	zakonczone	M	P	\N	\N	\N
180	Zbyt płytko wykonany otwór fi 14 (pracownikowi cofnęło wiertło) Należy poprawić na wiertarce.	\N	zakonczone	P	P	\N	\N	\N
181	Wymiar 40 H8 jest "uszkodzony" o 0,06 wymiaru. Zalecana Karta kontrolna.	\N	zakonczone	P	P	\N	\N	\N
182	Brak mycia przyłączy i króćców przed spawaniem	\N	zakonczone	\N	\N	\N	\N	\N
183	Brak informacji/ tabeli z zaznaczeniem tolerancji dla wymiaru fi 40 k7 z operacji 10	\N	zakonczone	P	P	\N	\N	\N
184	Nie zachowana tolerancja bicia otworu fi 81H7 0,1mm do otworu fi 63H9. Wykonano do 0,7 mm. Brak współosiowości otworu do roztoczenia.	\N	zakonczone	M	P	\N	\N	\N
185	Należy poprawić gwint na rysunku.	\N	zakonczone	P	P	\N	\N	\N
186	Nie zachowany wymiar kanałka pod pasek L-9,7 +0,2, wykonano na L-9,4	\N	zakonczone	M	P	\N	\N	\N
187	Uszkodzone tłoczyska (wszytskie w jednym miejscu)	\N	zakonczone	M	P	\N	\N	\N
188	Dziury na fi 50 (0-0,1) powstałe po wypaleniu. Zalecene zwiększenie naddatku przy wypaleniu od strony czopa.	\N	zakonczone	P	P	\N	\N	\N
189	Ponownie zadzior, ostra krawędź na gwincie M115x2	\N	zakonczone	M	P	\N	\N	\N
190	10 złe 17 ok	\N	zakonczone	M	G	\N	\N	\N
192	Uszkodzone okno na galwanizerni, opady atmosferyczne dostają się do srodka.	\N	zakonczone	\N	\N	\N	\N	\N
195	Ostra krawędź w otworze przyłącza	\N	zakonczone	M	P	\N	\N	\N
196	Zmienic proces, bądź operacje 10 (wiercenie) wykonać na SKT	\N	zakonczone	P	P	\N	\N	\N
198	Uszkodzenia na powłoce chromowanej, dużej wielkości wżery	\N	zakonczone	M	G	\N	\N	\N
199	Niezgdność wymiaru fi 33 na rysunku z wymiarem fi 32 (+0,2) w opisie w operacji 15 toczenia	\N	zakonczone	P	P	\N	\N	\N
200	Po cięciu rura nie została umyta do dalszych operacji (toczenia). Operator (Myszlin) wpisał operację, mimo iż nie została wykonana.	\N	zakonczone	P	P	\N	\N	\N
203	Uszkodzona faza L-3 20 stopni, w obudowie przez nóż do gwintowania, przy wyjściu noża z kanałka fi 105,5 H12	\N	zakonczone	M	P	\N	\N	\N
205	Brak operacji cechowania w dokumentacji	\N	w trakcie	M	P	\N	\N	\N
207	Detal został poszlifowany na gotowo 19.07.24 stoi na produkcji (korozja)	\N	zakonczone	P	P	\N	\N	\N
208	Wprowadzić kartę pomiarową na wymiar fi 50 H8 + FAZA. Problem z zachowaniem wymiaru.	\N	zakonczone	P	P	\N	\N	\N
209	Brak miejsca przy stanowiku kontrolnym na montażu. Zbyt duża ilość palet- z wadliwymi, uszkodzonymi detalami	\N	zakonczone	M	P	\N	\N	\N
210	Wymiar fi 66,2 h9 (66,126-66,200) jest 66,090- sprawdzian do kanałka wpada.	\N	zakonczone	P	P	\N	\N	\N
211	Brak operacji kalibrowania gwintu M30x2	\N	zakonczone	P	P	\N	\N	\N
212	Problemy z malowaniem (zamalowywaniem łożysk)	\N	w trakcie	M	P	\N	\N	\N
215	Nie naniesiono zmian do dokumentacji technologicznej. Pracownik wykonał operację toczenia, wg. niezaktualizowanej wersji. Na kolejnej zmianie inny pracownik wykonał poprawki. Zmienić tolerancję w operacji 25 fi 632 -0,1 na 63,1 - 0,1. W siłowniku CJ-S137-90/2.01 analogiczna sytuacja.	\N	zakonczone	P	P	\N	\N	\N
216	Dziury w powłoce chromowanej.	\N	zakonczone	P	G	\N	\N	\N
217	Po operacji nr 10 dodać zabielenie pod podtrzymkę aby wyeliminować bicie.	\N	zakonczone	P	P	\N	\N	\N
218	Liczne deziury i wżery po chromie na fazie. 3 szt do wytrawienia.	\N	zakonczone	P	P	\N	\N	\N
219	Spoina spawu wchodzi pod zgarniacz	\N	w trakcie	M	P	\N	\N	\N
220	Nie wymieniono rysunków na nowe (aktualne). Pracownicy otrzymali pierwotnie rys przed zmiana, bez wszystkich wymiarów	\N	zakonczone	P	P	\N	\N	\N
221	Aktualizacja rysunku 13.06.24. Operacja 40 toczenia zgodna z rysunkiem poza nr programu 0752, który jest nieaktualny. Pracownik na II zmianie sam aktualizował program.	\N	zakonczone	P	P	\N	\N	\N
222	Wióry w przyłączach G-1 i niewłaściwa obróbka	\N	zakonczone	M	P	\N	\N	\N
224	Operacja 15- toczenie posiada wymiar na rysunku fi 104,5 (0;-0,1), w opisówce fi 104-6 (-0,05)	\N	zakonczone	P	P	\N	\N	\N
225	4.03- 24 szt dziury; 08.03- 1 szt dziury, 13 szt pol	\N	zakonczone	P	G	\N	\N	\N
227	Wyciek oleju spod korków zabezpieczających. Zostały za mocno dokręcone, bokami wychodzi gumowa uszczelka.	\N	zakonczone	M	P	\N	\N	\N
228	Bicie na szykce tłoczyska 0,05 przekroczona ponad 0,1	\N	zakonczone	P	P	\N	\N	\N
229	Przeniesienie zagniatania łożysk wahliwych na produkcję	\N	zakonczone	P	P	\N	\N	\N
230	Za mała szczelina do spawania. Wykonalismy faze 20 stopni na tuleji cylindra.	\N	zakonczone	P	P	\N	\N	\N
232	Rusunki dą nieaktualne. Wymiar fazy od strony gwintu M24-1,5 jest niegodny z opisówką.	\N	zakonczone	P	P	\N	\N	\N
235	Niewłaściwie myte detale	\N	zakonczone	P	P	\N	\N	\N
239	Według technologii proces należy spawac na automacie. Pracownik jednak miał wykonać operację podczas spawania ręcznego. Nie było wyznaczonych czasów w tym zakresie	\N	zakonczone	P	P	\N	\N	\N
240	Ponowna korozja na uchu tłoczyska.	\N	zakonczone	M	G	\N	\N	\N
241	31 szt- brak chromu (38%); 21 szt polerowanie fazy (28%); 27 szt ok	\N	zakonczone	P	G	\N	\N	\N
242	Brak wymiaru 26 (+/-0,3)- jest 24,5-25,3. Brak fazy 1x45 stopni. Brak wymiaru 5 mm na śr fi 27,2 H7. Po rozpoczęciu toczenia pierwsze 32 szt wykonano właściwie. Zamiennik celem skorygowania bicia przetoczył szczęki, wcześniej zmniejszając ciśnienie. Po przetoczeniu szczęk nie wrócił do poprzednich parametrów. Szczęki nie trzymały stabilnie materiału w trakcie toczenia.	\N	zakonczone	P	P	\N	\N	\N
243	Uszkodzona uszczelka na tłoku podczas prób. Ostra krawędź na spirali w obudowie.	\N	zakonczone	M	P	\N	\N	\N
244	wióry w otworach fi 6	\N	zakonczone	P	P	\N	\N	\N
246	niezgodność wymiarwa ucho, tłoczysko, spawanie fi 25 a fi 28	\N	zakonczone	P	P	\N	\N	\N
247	Brak dokumentacji zaślepki pod otwór na smarowniczkę	\N	zakonczone	M	P	\N	\N	\N
248	Nie usunięte odpryski po spawaniu w otworach M20 i 1/4. Gwinty nie kalibrowane.	\N	zakonczone	M	P	\N	\N	\N
250	w otworze m8-6h- wióry, uszkodzenie gwintu m56x2 przez nieumiejętną obróbkę otworu m8-6h	\N	zakonczone	P	P	\N	\N	\N
252	Propozycja zmiany kształtu kanałka 60 stopni, głębokość 0,4 na promień. Pracownicy sugerują się rys wykonują kanałek nożem zamiast płytką promieniową i zwiększaja pracochłonność przez dodatkową operację honowania, która może być zbędna.	\N	w trakcie	P	P	\N	\N	\N
253	rysy spowodowane wsuwaniem do tekturowej otuliny zanieczyszczonej wiórami	\N	zakonczone	P	P	\N	\N	\N
254	Odpryski spawalnicze na montazu. Na gwintach przyłączy, stozku, zabieleniu (czoło przyłącza). Dziennie od kilku do kilkunastu sztuk do kalibrowania.	\N	zakonczone	M	P	\N	\N	\N
255	drobne wióry w rurce po obróbce ślusarskiej	\N	zakonczone	M	P	\N	\N	\N
256	po spawaniu tuleji i denka w środku zostaje mały przetop, może uszkodzić tłok	\N	zakonczone	P	P	\N	\N	\N
257	Wymiar 30+- 0,1 z operacji 25 niezgodny z rysunkiem i jego wymiarem	\N	zakonczone	P	P	\N	\N	\N
259	Pracownik po przez nieprawidłowe mocowanie na centrum zagniótł średnicę zewnętrzną rury- owal 0,7 mm. Owal przeniósł się na średnicę wewnętrzna gwintu M68x2 (sprawdzian się nie wkręca. Wal na średnicę fi 64H9 za gwintem 0,1 mm	\N	zakonczone	P	P	\N	\N	\N
261	Brak operacji obróbki ślusarskiej po nacięciu spirali	\N	zakonczone	P	P	\N	\N	\N
262	Operacja nr 5. Zalecane dodanie do wypalania otwór w środku obejmy	\N	zakonczone	P	P	\N	\N	\N
263	po wykonaniu operacji 35 nadal jest bicie na szyjce do 0,20   stary, nieczytelny rysunek	\N	zakonczone	P	P	\N	\N	\N
264	Nie zachowana tolerancja bicia gwintu M115x2 względem otworu fi 110 H8	\N	zakonczone	M	P	\N	\N	\N
265	Po operacji 10 (toczenie)  dopisac obróbkę otworu z częsci "C" o wymiarze 10	\N	zakonczone	P	P	\N	\N	\N
266	Po umyciu na montażu, detale nie zostały odpowiednio zabezpiecznone do transportu na produkcję. Nie wkręcono metalowych zaślepek 3/4 w przyłącze i silikonowych zaślepek w rurkę. Niezabezpieczone sztuki przytransportowano na produkcję.	\N	zakonczone	P	P	\N	\N	\N
267	Tuleja prowadząca(50850205) uszkodziła tłoczysko podczas montazu i na próbach (rysy)	\N	zakonczone	M	P	\N	\N	\N
268	dzoiry w spoinie na tłoczysku (wyłapane na malarni po malowaniu)	\N	zakonczone	M	P	\N	\N	\N
270	Brak umieszczonej zaślepki w otworach (śruba dociskowa M6x8). Detale cofnięte z malarni. Brak aktualizacji rys (brakuje otworu w uchu na rys złożeniowym- utrudniona praca kontroli)	\N	zakonczone	M	P	\N	\N	\N
271	Propozycja zmiany rozstawu otworu fi 8 pod klucz z wymiaru 60 na 64. Lepszy efekt wizualny, kanałek jest wystarczająco daleko. 	\N	zakonczone	P	P	\N	\N	\N
272	brak chropowatości	\N	zakonczone	P	P	\N	\N	\N
274	Brak aktualnej dokumentacji i programu. Tłoczyska w dalszym ciągu posiadają ostre krawędzie i wióry/ pierścionki- program nie został zmieniony. Dodatkowo występują błedy w rysunku i opisówce. 	\N	zakonczone	P	P	\N	\N	\N
276	Sporych rozmiarów wżery na całej dłogości detalu w powłoce chromowanej	\N	zakonczone	M	G	\N	\N	\N
277	Skorodowane ucho na tłoczysku.	\N	zakonczone	M	P	\N	\N	\N
279	Niezgodność rysunku z opisówka dotyczącą wymiaru w operacji 20.	\N	zakonczone	P	P	\N	\N	\N
280	Duża zendra po spawaniu	\N	zakonczone	M	P	\N	\N	\N
281	Pracownik poprełnił błąd, źle przeczytał dokumentacje, nie obrócił detalu. Rysunek może być mylący. Prośba w zaznaczenie na rurce 3D, że rysa jest po przeciwnej stronie kalamitki.	\N	zakonczone	P	P	\N	\N	\N
282	Wymiar fi 60 m6 (+0,030; +0,011) jest -0,1. DOPUSZCZONE WARUNKOWO.	\N	zakonczone	P	P	\N	\N	\N
283	Wykonanie niezgodne z procesem technologicznym. Detale z produkcji trafiły bezpośrednio na montaż i zostały zmontowane. Powinny uprzednio zostać przetransportowane na chromownie i być poddane procesowi polerowania.	\N	zakonczone	P	P	\N	\N	\N
284	3x wżery na powłoce chromowanej; 3x tarka	\N	zakonczone	M	G	\N	\N	\N
285	Pomimo użycia tulejek zabezpieczających dalej na tłoczysku pozostaje pierścień maralski. Dotyczy wszystkich cylindrów CD.	\N	zakonczone	M	P	\N	\N	\N
286	4 szt. Tarka na powierzchni nurnika/ 1 szt brak chromu na końcówce nurnika/ 3 szt wżery w chromie/ 2 szt uszkodzenia, rysy	\N	zakonczone	M	G	\N	\N	\N
287	Brak aktualizacji dokumentacji. Zlecenieotwarto 16.04.24 KZ 22.05.24. Wykonywano we wrześniu ze starym rysunkiem	\N	zakonczone	P	P	\N	\N	\N
288	Wżery w powłoce chromowanej, detale leżakowały 1,5 msc	\N	zakonczone	M	G	\N	\N	\N
289	Wżery i rozwarstwienia w otworze fi 110 H9	\N	zakonczone	M	P	\N	\N	\N
290	Na rys. wyiar 134 mm, na opisówce i programie 138 mm. Pracownik, źle wykonał detale. Jest mozliwość naprawy po przez ponowne toczenie na wymia 134 mm i wykonanie dodatkowej operacji na wiertarce	\N	zakonczone	P	P	\N	\N	\N
291	Brak kanałka pod zabezpieczenie tłoka. Dopuszczone przez konstruktora- zagniatanie punktowe	\N	zakonczone	M	P	\N	\N	\N
292	Uszkodzona powierzchnia nurnika na próbach. Ostra krawędź fazy w tulei prowadzącej	\N	w trakcie	M	P	\N	\N	\N
293	Pierścionki w kanałkach pod uszczelką	\N	zakonczone	M	P	\N	\N	\N
296	Tarka na tłoczysku, brak szczelności w chromie.	\N	zakonczone	P	P	\N	\N	\N
298	Tarka przy fazie montażowej na dłgości ok 50 mm. Częsciowo dopuszczone w detalach =, w których tarka nie dochodzi do uszczelki.	\N	zakonczone	M	P	\N	\N	\N
299	Odpryski po spawaniu	\N	zakonczone	M	P	\N	\N	\N
300	Preciek na rurce	\N	zakonczone	M	P	\N	\N	\N
303	Na rys. jest faza 4x45 st.  A w opisówce w operacji 10 "toczyć promień R1 i średnicę fi 85 (+/- 0,3) na ł L-50 (+0,1). Nurnik po spawaniu jest toczony na fi 84 (0;-0,1) i z promienia R1 nic nie zostanie, a na rysunku jest faza 2,5 x 45 stopni.	\N	zakonczone	P	P	\N	\N	\N
304	Operacja 30 (obróbka ślusarska) odbywa się na stanowisku pakowania i konserwacji, w wyniku czego może dojść do zanieczyszczenia detali podczas konserwacji i pakowania	\N	zakonczone	P	P	\N	\N	\N
305	Poprawić zabielenie pod króciec na fi 20 na rysunku	\N	zakonczone	P	P	\N	\N	\N
306	Spawanie wykonane niezgodnie z technologią: wąskie lico spoiny, obydwie warstwy w osłonie CO2	\N	zakonczone	P	P	\N	\N	\N
307	Na rysunku jest wymiar 12. Ucho z kooperacji MAX POWER zmienione- ma wymiar 8. Zostało warunkowo puszczone. Denko ma wymiar 5. Należy zmienić wymiar z 12 na rysunku- uaktualnić	\N	zakonczone	P	P	\N	\N	\N
308	Uszkodzenia mechaniczne króćców	\N	zakonczone	M	P	\N	\N	\N
311	Obita powierzchnia tłoczyska przez płytę. Detale nieodpowiednio ułożone/ zabezpieczone w palecie.	\N	zakonczone	M	P	\N	\N	\N
312	1) Luźny gwint M42x3. 1 szt wykonana na śr. Fi 40, 1 szt fi 41.2) Brak przyrządu do zagniatania łozyska w uchu i obudowie. Dotyczy to również innych detali-nie ma czym zagniatać.	\N	zakonczone	M	P	\N	\N	\N
314	Pierścien w dolnej części kanałka pod pasek.	\N	zakonczone	M	P	\N	\N	\N
315	Ciasny gwint M 48x2	\N	zakonczone	M	P	\N	\N	\N
316	Uszkodzona smarowniczka M6 (12 szt. Brak obróbki krawędzi otworu fi 40,2. Detale zabrane do malarni. Przed procesem malowania zidentyfikowano po raz kolejny uszkodzone smarowniczki.	\N	zakonczone	M	P	\N	\N	\N
317	Tarka na końcach nurników	\N	zakonczone	\N	\N	\N	\N	\N
318	Brak operacji kalibrowania gwintu M36x2-6H	\N	zakonczone	P	P	\N	\N	\N
319	Brak możliwości wiercenia centrycznego w osi tulei korpusu poz 2 otworu fi 20,5 (+0,2;0). Tulejki ściągają przy spawaniu do denka. Otwory zostały wykonane w osi tulejki z pominięciem głównej osi tylei cylindra. - Pracownik sam poprawił program i zminimalizował ilość braków.	\N	zakonczone	P	P	\N	\N	\N
320	Tarka po szlifowaniu i chromowaniu	\N	zakonczone	M	P	\N	\N	\N
321	Wżery, uszkodzonia powłoki chromowanej, 8 szt. Zadrgany gwint M48x2- 5 szt. (szlif 01-02/07/24, chrom 09-10/07/24)	\N	zakonczone	M	G	\N	\N	\N
322	Krzywo przyspawane ucho. Różnica na grubości ścianki max do 6 mm. Otwór wykonany w osi.	\N	zakonczone	M	P	\N	\N	\N
323	Wżery w materiale w 50 szt. Po dwukrotnym polerowaniu odpało 15 szt.	\N	zakonczone	M	P	\N	\N	\N
325	tłoczyska ponownie przeglądane przy lepszym oświetleniu na stanowisku kontroli; 23 szt- wytrawienie; 4 szt- do polerowania	\N	zakonczone	P	G	\N	\N	\N
326	Zadziory w podtoczeniu fi 51H9 na odległości 6 mm i ostre krawędzie wewnątrz tulei od drugiej strony. Pracownicy zareagowali na nie dopracowany program)	\N	zakonczone	P	P	\N	\N	\N
327	regeneracja myjni- obudowy	\N	zakonczone	P	P	\N	\N	\N
328	Wymiar fi 121 (+0,8 do +1,3) powinien być (+0,08 d o+0,13); w opisówce +0,013 powinno być +0,13	\N	zakonczone	P	P	\N	\N	\N
329	brak chrop, powierzchnia dogniatania fi 40 Rz 2,5 a jest 3,8	\N	zakonczone	P	G	\N	\N	\N
330	Brak prostopadłości przyłącza względem ucha. 8 szt zatrzymano, reszta dopuszczona warunkowo.	\N	w trakcie	M	P	\N	\N	\N
331	Zadzior na wyjściu gwintu M75x2. W korpusie przyłącza odpryski po spawaniu. Duże spawalne wióry w otworze	\N	zakonczone	M	P	\N	\N	\N
332	Brak zabezpieczeń na przyłącza i odpowietrzniki do transportu obudowy	\N	zakonczone	M	P	\N	\N	\N
333	Wżery w powłoce chromowanej	\N	zakonczone	M	G	\N	\N	\N
335	Uszkodzona tulejka BS podczas wciskania do obudowy (7szt) i tłoczyska (10 szt)	\N	zakonczone	M	P	\N	\N	\N
337	Nurniki spawane- nie usunięte odpryski.	Zbyt krótkie osłony?	zakonczone	M	P	\N	\N	\N
338	Pory w miejscu spawania końcówki tłoczyska do rury tłoczyska	\N	zakonczone	M	P	\N	\N	\N
339	Niezgodność wymiarów na rysunku i opisówce. Dwa inne wymiary dotyczące długości "L"	\N	zakonczone	P	P	\N	\N	\N
340	Ponowna prośba o zwiększenie zakresu obróbki w operacji 15, o gzymkowanie krawędzi otworu fi 17 i fi 22 oraz stępienie krawędzi zewnętrznych płyty. Wykonanie tych czynności po spawaniu płyty do tłoczyska, bardzo utrudnia wykonanie tych operacji, wygodniej zrobić je wcześniej. 	\N	w trakcie	P	P	\N	\N	\N
341	Nieusunięte odpryski po spawaniu	\N	zakonczone	M	P	\N	\N	\N
342	Brak operacji trasowania na maszynę PUMA 2600 MB	\N	zakonczone	P	P	\N	\N	\N
343	Propozycja opracowania metody obróki kilku detali jednocześnie na Centrach.	\N	w trakcie	\N	\N	\N	\N	\N
344	Tulejka fi 12 nie wchodzi w otwór w obudowie fi 12	\N	zakonczone	P	P	\N	\N	\N
345	Wżery w otworze fi 110, odpowiedzialny dostawca.	\N	zakonczone	M	P	\N	\N	\N
346	Pakować po wysłaniu na montaż od razu, aby nie pojawiła się korozja. Ostatnia partia pakowana była po miesiącu leżakowania na montażu.	\N	zakonczone	P	P	\N	\N	\N
347	Przesunięcie otworu fo 25,5 (+0,2; 0) względem ścianek, niezachowany wymiar otworu	\N	zakonczone	P	P	\N	\N	\N
348	Pozostawiony pierścień w kanałkach obudowy po obróbce mechanicznej	\N	zakonczone	M	P	\N	\N	\N
349	Nie zachowany wymiar kanałka pod pasek fi 75 H9. Wykonano fi 74,75	\N	zakonczone	M	P	\N	\N	\N
350	Bardzo duża ilość odprysków spawalniczych, na całym cylindrze. Zauważono dopiero po operacji malowania.	\N	zakonczone	M	P	\N	\N	\N
351	Przeciek przez nakiełek w denku	\N	zakonczone	M	P	\N	\N	\N
352	Po wycięciu materiału praconik wpisał operację mycia, mimo iż jej nie wykonał. W środku zostało zaschnięte chłodziwo. 	\N	zakonczone	P	P	\N	\N	\N
354	Nie zachowany wymiar otworu fi 20 (+0,2) w tłoczysku- jest 19,9. Detale sprawdzone z magazynu. 	\N	zakonczone	M	P	\N	\N	\N
355	Wymiar fi 34 H7 (+0,250 poza tolerancją do 0,05-0,06	\N	zakonczone	P	P	\N	\N	\N
357	Odpryski na powierzchni chromowanej nurnika	\N	zakonczone	M	P	\N	\N	\N
358	Brak podtoczenia pod potrzymkę. Powstawanie owalu na rurze w czasie spawania- nadmierne nagrzewanie materiału.	\N	zakonczone	P	P	\N	\N	\N
359	Wprowadzić na stałe fazę w tulei cylindra do spawania z korpusem tw "zamek" jest za mały i nie gwarantuje prawidłowego przetopu. Fazy do poprawy na tur-63	\N	w trakcie	P	P	\N	\N	\N
360	Przeciek przez oring. Wymiar w obudowie pod oring fi 39H9, wykonano na fi 41.	\N	zakonczone	P	P	\N	\N	\N
362	zardzewiała, cieknąca rura na montazu przy wejściu od rozdzielni, woda kapie na detale	\N	zakonczone	P	P	\N	\N	\N
364	Pracownik nie może wykonać detalu (54 szt), podczas uruchomienia zlecenia (pierwszy raz). Nie ma oprzyrządowania ani inf w opisówce.	\N	zakonczone	M	P	\N	\N	\N
365	Ciasne pierścienie względem kuli. Po wkręceniu blokują kulę. 4 seriia z rzędu (w tym roku)	\N	w trakcie	M	P	\N	\N	\N
366	Źle wykonana obróbka wykończeniowa w otworze pod rurkę. Dodatkowo rozwarstwienia w otworze fi 110	\N	zakonczone	M	P	\N	\N	\N
367	Cylindry do Agromaszu. Czasy są zbyt któtkie aby sprawdzić przelew wew. z dwóch stron. Czas honowania również do sprawdzenia	\N	zakonczone	M	P	\N	\N	\N
368	Tłoczysko nie pochromowane z przyspawanym uchem  trafiło na montaż. (1 szt z 102 szt)	\N	zakonczone	M	P	\N	\N	\N
370	Brak 	\N	zakonczone	P	G	\N	\N	\N
371	nie można dokręcić tłoka, ani zabezpieczyć wkrętem. Gwinty M8 x 1,5 i M56x2	\N	zakonczone	P	P	\N	\N	\N
373	Nieodpowiednia faza do spawania co skutkuje podtopieniami zabielenia pod króciec	\N	zakonczone	P	P	\N	\N	\N
374	Przy toczeniu spoiny na sr. Zew. Nurnika pozostawiały plamy. Wystapiła konieczność obniżenia średnicy fi 69,8 (0;-0,2). Po toczeniu zostaje ostra krwędź na kanałku. Zalecana zmiana wykonania końcówki nurnika, zwiększenie średnicy zew. I nie nacinanie kanałka. Wykonanie kanałka przenieśc do operacji toczenia po spawaniu.	\N	\N	P	P	\N	\N	\N
375	Licznie porowaty chrom (37 złych na 50)	\N	\N	M	G	\N	\N	\N
376	Brak obróbki  w otworze pod przyłączami	\N	zakonczone	M	P	\N	\N	\N
377	Otwory fi 6 w rozstawie 64 mm wykonano fi 8 w rozstawie 60 mmm- niezgodność opisówki i programu z rysunkiem	\N	zakonczone	P	P	\N	\N	\N
378	Faza przed gwintem G1/4 fi 13,2 (+/0,1) jest fi 14,6. Długość gwintu G1/4 w obu gniazdach powonna być 15mm a jest 13,5	\N	zakonczone	P	P	\N	\N	\N
379	Niedrożny cylinder (zaspawana rurka)	\N	zakonczone	M	P	\N	\N	\N
380	Należy poprawić gwint na rysunku oraz okreslić właściwą tolerancję.	\N	zakonczone	P	P	\N	\N	\N
381	ciasny gwint	\N	zakonczone	P	P	\N	\N	\N
382	Brak obróbki kanałka pod zabezpieczenie	\N	zakonczone	M	P	\N	\N	\N
383	21 szt dziury. Wystapiły wady materiałowe. Materiał został próbnie wykorzystnany z resztek produkcyjnych R-ów(rura 80H8x90- 0463831156). Próbna produkcja nie przyniosła planowanych rezultatów. Zablokowano dalsze użycie materiału.	\N	zakonczone	P	G	\N	\N	\N
384	Niezgodny wymiar otworu H11 rysunku z opisówką. Brak wymiaru d9 w opisie w odpowiedniej operacji.	\N	zakonczone	P	P	\N	\N	\N
385	Brak rys do spawania na obudowie i korpusie	\N	zakonczone	P	P	\N	\N	\N
386	Tłoczyska na chromowni nie zostały zakonserowane po polerowaniu, wyszła korozja.	\N	zakonczone	P	P	\N	\N	\N
387	Zacieki na tulejach prowadząccych (schodzi cynk)	\N	zakonczone	M	P	\N	\N	\N
388	Nieszczelna powłoka galwaniczna, wszystkie tłoczyska poddane próbie ferroksylowej wykazały znacznej ilości nieszczelności	\N	zakonczone	M	G	\N	\N	\N
390	Długość L niezgodna na opisówce	\N	zakonczone	P	P	\N	\N	\N
391	Brak operacji obróbki w procesie, dot. otworów i zewnętrznych krawędzi w płetwie	\N	w trakcie	M	P	\N	\N	\N
392	po planowaniu została wypustka	\N	zakonczone	P	P	\N	\N	\N
393	7 szt wytrawianie (dzióry), 2 szt polerowanie	\N	zakonczone	P	P	\N	\N	\N
394	rysy wzdłużne i poprzeczne na tłoczysku	\N	zakonczone	M	P	\N	\N	\N
395	Nie można załozyć przyłącza G1/8. Podczas spawania korpusu spoina zalała zabielenie pod przyłącze G 1/8	\N	zakonczone	M	P	\N	\N	\N
396	Licznie porowaty chrom	Wanna nie została odpowiednio rozgrzana, ogrzewanie z PEC-u było za słabe.	\N	M	G	\N	\N	\N
399	Łożyska, tulejki wciskane są niejednokrotnie po próbach i po cechowaniu.	\N	w trakcie	M	P	\N	\N	\N
400	Zadzior, ostra krawędź na wejściu gwintu M115x2. Podczas wkręcania do obudowy zacierają się cylindry.	\N	zakonczone	M	P	\N	\N	\N
401	otwór fi 10 z pogłębieniem fi 25 w tuleji cylindra wykonano niezgodnie z rysunkiem	\N	zakonczone	P	P	\N	\N	\N
402	Błąd w dokumentacji. Źle dobrany pierścień uszczelniający (7,3) pod kanałek (6,,3) 	\N	zakonczone	M	P	\N	\N	\N
404	Przy cięciu na pile brak prostopadłości powierzchni viętej do poziomu pręta fi 100 (cięcie na tzn "kiełbasę")	\N	zakonczone	P	P	\N	\N	\N
405	Na produkcji wystepuje problem z jakością palet- wystepuja pozostałości wiórów oraz inne zanieczyszczenia.	\N	zakonczone	P	P	\N	\N	\N
407	Podczas wciskania tulei ślizgowej został zagnieciony otwór fi 45. Nie można włozyć sworznia w tulejkę fi 40.	\N	zakonczone	M	P	\N	\N	\N
408	Niewłaściwe zabezpiecenie detali do transportu	\N	zakonczone	M	P	\N	\N	\N
410	Odpryski po spawaniu w gwintach przyłącza: M20 i G 1/4. 	\N	zakonczone	P	P	\N	\N	\N
412	storzek na fi 53 h9 jest poza tolerancją od 0,01 do 0,04	\N	zakonczone	P	P	\N	\N	\N
413	Powrót na Produkcję, poprawa spirali, obróbka na honowaniu. Kolejne dwa razy powrót na Produkcje przez ostre krawędzie na wyjściu gwintu wewnątrz obudowy. 	\N	zakonczone	M	P	\N	\N	\N
414	Wióry w przyłączu M10x1. Wykryto na próbach.	\N	zakonczone	M	P	\N	\N	\N
415	ostra krawędź w spiralce	\N	zakonczone	P	P	\N	\N	\N
416	Przesunięcie osiowe tuleji z otworem fi 20 w uchu. Nie wycofane denka starego typu z magazynu.	\N	zakonczone	P	P	\N	\N	\N
418	Eymiar G=23(+2,0) z operacji 15 jest niezgodny z wymiarem na ryzunku	\N	zakonczone	P	P	\N	\N	\N
421	Zmienić tolerancję w otworze fi 50H8 na fi 50(+0,05/+0,08)	\N	w trakcie	\N	\N	\N	\N	\N
422	Wgniecenia ujawnione po operacji polerowania a przed wierceniem. W środkowej częsci nurnika, na tej samej odległości, w każdej sztuce w palecie.	\N	zakonczone	P	P	\N	\N	\N
423	Nie usunięty pierścień z kanałka zewnętrznego fi 48 wyjścia gwintu M50x1,5	\N	zakonczone	M	P	\N	\N	\N
424	Tabelka z tolerowanymi wymiarami niezgodna z rysunkiem	\N	zakonczone	P	P	\N	\N	\N
426	4 szt Wżery w chromie, nieszczelna powłoka/ 3 szt uszkodzenia, rysy	\N	zakonczone	M	G	\N	\N	\N
427	3 SERIA Z RZĘDU!!!!! Podczas wkręcania pierścienia w korpus, łozysko klinuje czop kulisty. Brak możliwości rotacji kuli	\N	zakonczone	M	P	\N	\N	\N
428	Niezgodności występujące w funkcjonowniu malarni, niezachowana czystość, brak bierzących wymian sprzętu	\N	zakonczone	P	P	\N	\N	\N
429	Zmienić tolerancję pod tłoczysko z pręta chromowanego	\N	zakonczone	P	P	\N	\N	\N
430	Brak informacji w opisówce o kontroli operacyjnej , na rysunku zaznaczone "S"-ki 	\N	zakonczone	P	P	\N	\N	\N
433	Długość tłoczyska- na rysunku 667+/-0,5 opisówka 662 +/- 0,5	\N	zakonczone	P	P	\N	\N	\N
434	dziury w chromie	\N	zakonczone	P	G	\N	\N	\N
435	Za krótki ząbek do spawania korpusu. Wystapił przetop.	\N	zakonczone	P	P	\N	\N	\N
436	Zniekształcone wyjście króćca (2/13 w serii)	\N	zakonczone	M	P	\N	\N	\N
437	Obicia nurnika na chromowni	\N	zakonczone	M	G	\N	\N	\N
438	Odwrotnie włozona zaślepka do spawania pod przyłącze G-1/4	\N	zakonczone	M	P	\N	\N	\N
439	Brak programu na wykonanie op. 15 dla skoku 110. W pierwszej sztuce wymiar A zamiast 175 mm wyszedł 190 mm (przestój pracownika od godz. 19 30 do 22)	\N	w trakcie	P	P	\N	\N	\N
440	Uszkodzenia mechaniczne- poobijane	\N	zakonczone	M	P	\N	\N	\N
441	Znaczne wżery w chromie na całej powierzchni tłoczyska.	\N	zakonczone	M	P	\N	\N	\N
443	Wżery na powierzchni chromowanej	\N	zakonczone	M	G	\N	\N	\N
445	Opisówka z dnia 18.03.24 podpięta pod przewodnik z oper. Nr 5(xxxxx). Poprawiona opisówka została wydrukowana 25.03.24. Brak noża ISCAR do wykonania otworu.	\N	zakonczone	P	P	\N	\N	\N
446	Nie można wkręcić tulei prowadzącej z tłoczyskiem z powodu bicia/współosiowości	\N	w trakcie	M	P	\N	\N	\N
447	Nie zachowana chropowatość powierzchni (tarka)	\N	zakonczone	M	G	\N	\N	\N
448	WYKONANO ZGODNIE Z RYS. Na rysunku kanałek 3,8 +0,2 na średnicy 56,8 H9 a w opisówce fi 55,2 H9	\N	zakonczone	P	P	\N	\N	\N
450	Tłoczysko po toczeniu 08.07.24, widoczna korozja na gwintach	\N	zakonczone	P	P	\N	\N	\N
451	Nie możlna zaślepić otworu w przyłączu zaślepką VSTI M20x1,5 ED. Długość gwintu w przyłączu L-11+1, w zaślepce L-14	\N	zakonczone	M	P	\N	\N	\N
452	Niedopuszczone odpryski spawalnicze na częsci chromowanej nurnika. 	\N	zakonczone	P	P	\N	\N	\N
453	17 szt dziury	\N	zakonczone	P	G	\N	\N	\N
454	Przy osadzaniu tłoka na gorąco nie zachowany wymiar 289(0-0,2)	\N	zakonczone	P	P	\N	\N	\N
455	po polerowaniu	\N	zakonczone	P	G	\N	\N	\N
456	Krzywo przyspawany korpus w odniesieniu do poziomu króćca. Błąd spawacza w ustawieniu korpusu względem tuleji cylindra przed spawaniem.	\N	zakonczone	P	P	\N	\N	\N
457	Brak wprowadzonych faz 20 stopni pod spawane korpusy: CJ-S21-60/1.01-2, CJ-S163-70/1.01-2, CJ-S274-40/1.01-2, CJ-S75-25/1.01-2.	Nawał pracy w technologii.	zakonczone	P	P	\N	\N	\N
458	Błąd rysunku. Dotyczy łożyska- jest fi 55, powinno być fi 60	\N	zakonczone	M	P	\N	\N	\N
459	Pierścienie w kanałku pod uszczelkę i zgarniacz	\N	zakonczone	M	P	\N	\N	\N
460	Odpryski po spawaniu w otworach G-1/4 i M20x1,5	\N	zakonczone	M	P	\N	\N	\N
461	Brak obróbki spoiny od czoła tłoczyska (odpryski). Brak zaślepek transportowych	\N	zakonczone	M	P	\N	\N	\N
462	NIEPRAWIDŁOWOŚCI NA MALARNI. Wyciągnięty łańcuch w prowadnicy na myjce. Niedopuszczalny poziom czystości trawersów, opadające zanieczyszczenia na powierzchnię wykonywanych siłowników.	\N	w trakcie	M	P	\N	\N	\N
463	Przecieki na nurniku + 2 szt uszkodzenia mechaniczne	\N	zakonczone	M	P	\N	\N	\N
464	Niedokręcone ucho	\N	zakonczone	M	P	\N	\N	\N
466	Po demontażu obudowy z odpryskami w przyłączach zostały w celu poprawy, przekazane na produkcję. Wróciły z powrotem, ponownie je zmontowano, po czym okazało się iż nie zostały poprawione.	\N	zakonczone	M	P	\N	\N	\N
467	Korozja w otworze na denku. Niedomalowane ucha.	\N	zakonczone	M	P	\N	\N	\N
468	Ucho tłoczyska pospawane do surowego materiału (po polerowaniu przed chromem)	\N	zakonczone	P	P	\N	\N	\N
470	Wykonanie detali niezgodnie z technologia. Po wprowadzeniu karty zmian okazało się, że nie została zaaktualizowana cała dokumentacja. 	\N	zakonczone	P	P	\N	\N	\N
471	nie oczyszczony pierścień malarski po malowaniu na nurniku	\N	zakonczone	M	P	\N	\N	\N
472	Licznie porowaty chrom	\N	\N	M	G	\N	\N	\N
473	1 szt tarka na powierzchni galwanicznej/ 2 szt nieszczelna powłoka galwaniczna/ 6 szt liczne dziury wpływające na estetykę- nieszczelne	\N	zakonczone	M	G	\N	\N	\N
474	Nieszczelne spoiny przy króćcu	\N	zakonczone	M	P	\N	\N	\N
475	Wżery w materiale	\N	zakonczone	M	P	\N	\N	\N
476	Przeciek na króćcu, przeciek na denku) Dziury na spoinach.	\N	zakonczone	M	P	\N	\N	\N
477	Pracownik przy polerowaniu średnicy zew. Wciał się miejscowo w materiał powodując uszkodzenia bez możliwości naprawy. Do wykonania 56 szt, do złomu 30 szt	\N	zakonczone	P	P	\N	\N	\N
478	Sztuki z różnych materiałów, różna graniastość, po wielokrotnym szlifowaniu tej samem sztuki, chropowatośc dalej poza tolerancją. Tarka wyczuwalna pod paznokciem.	\N	zakonczone	P	P	\N	\N	\N
479	Kłęby wiórów w obudowie- bardzo duża ilość i wielkość	\N	zakonczone	M	P	\N	\N	\N
480	Żle wykonana obróbka kanałka pod drut zabezpieczający. Kanałek wykonany niezgodnie z rysunkiem (powinien być po prawej stronie od ucha, a ajest róźnie)	\N	zakonczone	M	P	\N	\N	\N
481	Błędnie oznaczona minusowa tolerancja na rysunku fi 35 (-0,1;-0,05)-powinna być K7	\N	zakonczone	P	P	\N	\N	\N
482	Odciśnięte ślady po wiórach, brak stępienia krawędzi w otworze di 8	\N	zakonczone	P	P	\N	\N	\N
483	Nieprawidłowy wymiar na rysunku 138 w porę poprawiony na 134 mm (sytuacja wyłapana przed wykonaniem korpusów)	\N	zakonczone	P	P	\N	\N	\N
484	Niewłaściwie ogratowany otwór fi 3,5 w obudowie (wióry, ostra krawędź)	\N	zakonczone	M	P	\N	\N	\N
485	Ostatni zwój gwintu odłamuje się od detalu powodując obecność wiórów. Tuleje poprawione na stanowisku KJ!!!	\N	zakonczone	M	P	\N	\N	\N
486	korozja na obudowie w środku	\N	zakonczone	P	P	\N	\N	\N
487	Opisówka nie zawiera treści o umiejscowieni u wymiaru fi 51 d9 w odpowiedniej operacji	\N	zakonczone	P	P	\N	\N	\N
488	W opisówce średnica fi 121 (+0,08 do + 0,013) powinno być fi 121 (+0,08 do +0,13)	\N	zakonczone	P	P	\N	\N	\N
489	Zanieczyszczenia w otworze fi 14 pod przetwornik w postaci śladów bezwodnika przez 	\N	zakonczone	M	P	\N	\N	\N
491	Niezgodność do tycząca ilości otworów fi 6- na rysunku jest ilość 2, na opisówce (operacja 10) ilość 4	\N	zakonczone	P	P	\N	\N	\N
492	Porowata spoina (43 sztuki), Pierościonki w kanałkach pod pasek i uszczelkę. (70)	\N	zakonczone	M	P	\N	\N	\N
493	Brak przyrządu do spawania	\N	zakonczone	P	P	\N	\N	\N
494	Przyrząd SPx 15918- nie zapewnia położenia listwy wg rys- jest ciasny, denko szersze od tulei cylindra	\N	zakonczone	P	P	\N	\N	\N
495	Brak rys ustawnych- spawanie	\N	zakonczone	P	P	\N	\N	\N
496	Wymiar sworznia L-64(+1,+0,5) wykonanao L-63,8. Wymiar uchwytu (64) Wykonano na 65,5/65,5. Nie można zmontować zestawu. Sworzeń jest w +nie-. Sworzeń lata w segerach.	\N	zakonczone	M	P	\N	\N	\N
497	Wymiar fi 32 H9- nie są podane granice tolerncji w tabeli w lewym górnym rogu.	\N	zakonczone	P	P	\N	\N	\N
498	Brak operacji kalibrowania gwintu.	\N	zakonczone	P	P	\N	\N	\N
469	Liczne pory na calej powierzchni nurników.	Wadliwy materiał	zakonczone	G	G	\N	\N	\N
501	11 szt dziury; tłoczysko pojechało na montaż bez podpisu kontrolera KJ. Podobno zostały przez niego zaakceptowane. Na montażu kontroler nie dopuścił detali i wróciły na produkcję .	\N	zakonczone	P	G	\N	\N	\N
502	bicie osiowe na szyjce tłoczyska znacznie poza tolerancją (pręty były prostowane i dwukrotnie szlifowane przed toczeniem)	\N	zakonczone	P	P	\N	\N	\N
503	Brak zaślepki do malowania na łozysko i zgarniacz- tuleje zostały zamalowane. Zaśleki powinny być przystosowane do zawieszenia na niej haka	\N	zakonczone	M	P	\N	\N	\N
504	Nieogratowane otwory fi 35 w obudowie	\N	zakonczone	M	P	\N	\N	\N
505	Brak faz montażowych pod tuleję prowadzcą. Nowy wyrób.	\N	zakonczone	M	P	\N	\N	\N
506	Odpryski na gwincie po spawaniu w otworach G 1/4 i M20x1,5	\N	zakonczone	M	P	\N	\N	\N
507	Skorodowany gwint M28x1,5 w tłoczysku po myciu na malarni.	\N	zakonczone	M	P	\N	\N	\N
508	Dziury w spoinie ujawnione po toczeniu tłoka	\N	zakonczone	P	P	\N	\N	\N
510	Licznie porowaty chrom (110 pochromowanych, wyszło 62 niezgodne)	\N	\N	M	G	\N	\N	\N
511	Rysa spiralna na 1/3 długości nurnika. Dopuszczone warunkowo.	\N	zakonczone	M	P	\N	\N	\N
512	Chromowana rura nurnika została obrobiona tarcza listkowa na długości 60-70 mm od zatoczenia na całym obwodzie.	\N	zakonczone	P	P	\N	\N	\N
513	Operacja 30. Wpisać kalibrowanie gwintu w otworach 2xG1/8	\N	zakonczone	P	P	\N	\N	\N
514	Wżery w powierzchni chromowanej	\N	zakonczone	M	G	\N	\N	\N
515	Chropowata powierzchnia detalu na powłoce chromowanej. Liczne wżery.	\N	zakonczone	M	G	\N	\N	\N
516	szlofiwanie 17.04 polerowanie 05.05	\N	zakonczone	P	G	\N	\N	\N
517	usunąć fazę z obudowy, spaw zalewa zabielenie pod krócicec oraz zwiększyć ząbek w denku na 3 mm	\N	zakonczone	P	P	\N	\N	\N
518	Zalecane zwiększenie wymiaru fazy o 0,2-0,3 mm pod gwint G1/2. Jest problem z wprowadzeniem sprawdzianu.	\N	zakonczone	\N	\N	\N	\N	\N
519	Dziury na powierzchni chromowanej	\N	zakonczone	P	G	\N	\N	\N
520	Prośba o zmianę średnicy w operacji 30 z fi 45,3 -0,01 na fi 45,3 -0,1	\N	zakonczone	P	P	\N	\N	\N
521	Podczas prób zauwazono, że płyta która jest wspawana na tłoczysku mocno sociska zgarniacz. Nie jest zachowany wymiar na tłoczysku L-75+-0,2, wykonano L-78-79	\N	zakonczone	M	P	\N	\N	\N
522	Pracownik założył nieodpowiedni pogłębiacz +0,2 śr fi 21,3 wyryta fi 22	\N	zakonczone	P	P	\N	\N	\N
523	wióry w otworach fi 8	\N	zakonczone	P	P	\N	\N	\N
524	Brak obróbki krawędzi ucha i ostre krawędzie otwaoru	\N	zakonczone	M	P	\N	\N	\N
525	Wymiar do przyłącza 43 mm, jest 46 mm. Rozdzielca pomylił przyłącza i zamiast CN-S19-55/2.03 wydał CN-S19-60/2.03	\N	zakonczone	P	P	\N	\N	\N
526	Cylinder pocechowano wg rysunku do firmy Dautel. Odbiorcą tego cylindra jest Sulej.	\N	zakonczone	M	P	\N	\N	\N
527	Niewłaściwa obróbka kanałka pod drut zabezpieczający (ostry rant)	\N	zakonczone	M	P	\N	\N	\N
528	Zgorzelina (nagar) po wypaleniu na wypalarce, powoduje "ruszanie" się detali w imadle. 	Niedokładość obrabiarki	zakonczone	P	P	\N	\N	\N
530	Bicie gwintu M36x2 względem srednicy fi 45f8 do 0,4 mm.	\N	zakonczone	M	P	\N	\N	\N
531	W dokumentacji cylinder powinien być malowany na kolor żółty RAL 1003 i tak został pomalowany (wcześniej dla TRANSDEKU ANG). Cylinder został sprzedany do innej firmy (HORMANN LEGNICA), kolor nie został zaktualizowany- powinien być szary. 	\N	zakonczone	M	P	\N	\N	\N
532	Po toczeniu brak końcowej operacji na stepienie krawędzi zew. Na kołnierzu i w otworach	\N	zakonczone	P	P	\N	\N	\N
533	brak operacji obróbki otworu fi 20 na odcięciu	\N	zakonczone	P	P	\N	\N	\N
535	po roztoczeniu średnicy fi 50 H9 na końcu zostają wióry	\N	zakonczone	P	P	\N	\N	\N
536	Przy roztaczaniu na fi 66 +/-0,3 dodać na początu na długości 5mm wymiar fi 66 (-0,03;-0,06) pod korpus ucha	\N	zakonczone	P	P	\N	\N	\N
537	Detale przewożone na montaż i chromownie- nie są zabezpieczone odpowiednio przed deszczem.	\N	\N	P	P	\N	\N	\N
538	Odpryski spawalnicze na powierzchni chromowanej. Po usunięciu ich na obudowie powierzchnia chromowana została jeszcze bardziej uszkodzona.	\N	zakonczone	M	P	\N	\N	\N
539	Odpryski po spawaniu w otworze fi 12	\N	w trakcie	M	P	\N	\N	\N
541	Nieusunięte odpryski z przyłączy M18x1,5	\N	zakonczone	M	P	\N	\N	\N
542	Na produkcje wydano nieaktualna opisówkę i rys Tłoczyska wykonanao po staremu i nie est możliwe połączenie tłoczysk z uchem (czop na tłoczysku M4, a otwór ucha M6)	\N	zakonczone	P	P	\N	\N	\N
544	Brak chromu, 12 szt dziury; 14 szt ok	\N	zakonczone	P	G	\N	\N	\N
545	Niezgodność dotycząca wykonania fazy w operacji 10 toczenia. Opisówka: 2,5 x20 rys 2x20	\N	zakonczone	P	P	\N	\N	\N
546	Korozja w otworze na denku	\N	zakonczone	M	P	\N	\N	\N
547	Brak kontroli międzyoperacyjnej na opisówce	\N	zakonczone	P	P	\N	\N	\N
548	Różnice programy z rysunkiem. Należy poprawić dł. Gwintu M 22x1,5 i dlugość szyjki z gwintem U w programie odpowiednio 27 mm i 38 mm, powinno być 28 mm i 39 mm)	\N	zakonczone	P	P	\N	\N	\N
549	11 szt dzióry, wytrawinie	\N	zakonczone	P	G	\N	\N	\N
66	Wymieszane części NOK, od klienta i z własnej produkcji, bez identyfikacji, bez jasnego statusu.	Duża ilość detali przekazanych do weryfikacji spowodowana była brakami kadrowymi osób zajmujących się ustaleniem przyczyn wad części.	w trakcie	\N	\N	\N	\N	\N
626	\N	funkcjonalność	w trakcie	\N	\N	spadł pierścień zabezpieczający	6.0	funkcjonalność
634	\N	ogólne	w trakcie	\N	\N	\N	\N	ogólne
68	Maszyna CMM nie jest udokumentowana, nie wiadomo, kiedy jest następny termin przeglądu	Centrum Obróbcze TV146 B  była i jest ujęta w rocznym planie przeglądów na dzień 04.03.2026r.\nOstatnio były naprawiane i wymieniane w tej maszynie\nkubki narzędziowe ( 05.03.2025r) - protokół naprawy .	w trakcie	\N	\N	\N	\N	\N
625	\N	uszkodz. uszczelnień ostra krawędź	w trakcie	\N	\N	uszkodzenie uszczelnień ostra krawędź	3.11	przeciek wewnętrzny
629	\N	wiór	w trakcie	\N	\N	wyciek po tłoczysku, wiór	2.21	wyciek zewnętrzny
627	\N	odkręcony tłok	w trakcie	\N	\N	wykręcony tłok od tłoczyska, brak wkręta	6.4	funkcjonalność
624	\N	niezachowane wymiary, problem z montażem	w trakcie	\N	\N	brak wpółosiowości, otwory przesunięte względem obudowy	6.1	funkcjonalność
70	Konserwacja komory lakierniczej nie jest udokumentowana	Założona jest książka konserwacji i napraw wszystkich urządzeń w malarni.\nNatomiast w rocznym planie przeglądów,  malarnia zaplanowana jest dwa raz w roku w czerwcu oraz grudniu.	w trakcie	\N	\N	\N	\N	\N
71	W niektórych obszarach produkcyjnych można by poprawić czystość i porządek.	Natok pracy oraz znaczne absencje pracowników. Niedostateczna egzekucja standardów 5s.	w trakcie	\N	\N	\N	\N	\N
98	W nowo dostarczonych siłownikach stwierdzono wyciek oleju.	Przeciek na połączeniu złączki.	w trakcie	\N	\N	\N	\N	\N
566	\N	funkcjonalność	w trakcie	\N	\N	zablokowane łożysko w uchu	6.0	funkcjonalność
568	\N	funkcjonalność	w trakcie	\N	\N	zerwany drut zabezpieczający	6.0	funkcjonalność
571	\N	funkcjonalność	w trakcie	\N	\N	ostra krawędź na średnicy ø18, brak fazy	6.0	funkcjonalność
202	Całe ucha w odpryskach, nie można montować tulejek.	Brak osłonek do spawania ręcznego rurki zasilającej. Nie wychwycenie odprysków na obróbce.	w trakcie	M	P	\N	\N	\N
611	\N	funkcjonalność	w trakcie	\N	\N	odprysk na gwincie w przyłączu	6.0	funkcjonalność
278	Nie można zmontować tłoczyska- za grube (+0,03)	Niewłaściwy materiał- tloczysko wykonano z gotowego materiału (chrom-nikiel)	w trakcie	M	P	\N	\N	\N
589	\N	niezachowane wymiary, problem z montażem	w trakcie	\N	\N	ciasny otwór w uchu obudowy ø20H12, wykonano na ø19,8	6.1	funkcjonalność
580	\N	wyciek zewnętrzny	w trakcie	\N	\N	przeciek po tłoczysku	2.0	wyciek zewnętrzny
574	\N	wyciek zewnętrzny	w trakcie	\N	\N	wyciek po tłoczysku	2.0	wyciek zewnętrzny
573	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	tarka na tłoczysku	4.1	uszkodzenia mechaniczne
572	\N	wyciek zewnętrzny	w trakcie	\N	\N	spoina rurka w korpusie	2.0	wyciek zewnętrzny
581	\N	wyciek zewnętrzny	w trakcie	\N	\N	wyciek zewnętrzny, brudny olej	2.0	wyciek zewnętrzny
569	\N	nie nasza produkcja	w trakcie	\N	\N	nie nasza produkcja	0.4	ogólne
582	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, cylinder rozkręcony, wykręcony zawór	0.2	ogólne
567	\N	wyciek zewnętrzny	w trakcie	\N	\N	wgłębienie na nurniku, uszkodzenie uszczelki	2.0	wyciek zewnętrzny
565	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	uszkodzenia na powierzchni tłoczysk	4.1	uszkodzenia mechaniczne
585	\N	konstrukcja	w trakcie	\N	\N	smarowniczka nie po właściwej stronie, nieprawidłowy rysunek	6.8	funkcjonalność
586	\N	wyciek zewnętrzny	w trakcie	\N	\N	przeciek po rurce w korpusie	2.0	wyciek zewnętrzny
562	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	urwany tłok	4.1	uszkodzenia mechaniczne
559	\N	spoina korpus	w trakcie	\N	\N	spoina korpus ucha, rysa na tłoczysku	2.12	wyciek zewnętrzny
557	\N	nie nasza produkcja	w trakcie	\N	\N	siłowniki nie naszej produkcji	0.4	ogólne
554	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, 1szt. uszkodzone tłoczysko, wykręcany zawór	0.2	ogólne
591	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	rysa na tłoczysku	4.1	uszkodzenia mechaniczne
553	\N	uszkodz. uszczelnień montaż	w trakcie	\N	\N	przeciek wewnętrzny, uszkodzenie uszczelnień 	3.1	przeciek wewnętrzny
579	\N	funkcjonalność	w trakcie	\N	\N	brak smaru w kanałku	6.0	funkcjonalność
622	\N	funkcjonalność	w trakcie	\N	\N	ciasny nurnik, za dużo chromu	6.0	funkcjonalność
619	\N	funkcjonalność	w trakcie	\N	\N	odpryski po spawaniu w przyłączu	6.0	funkcjonalność
550	\N	spoina inne	w trakcie	\N	\N	spoina rurka	2.13	wyciek zewnętrzny
594	\N	funkcjonalność	w trakcie	\N	\N	odrysk po spawaniu na gwincie w przyłączu	6.0	funkcjonalność
588	\N	funkcjonalność	w trakcie	\N	\N	brak tłoka pływającego w obudowie	6.0	funkcjonalność
599	\N	funkcjonalność	w trakcie	\N	\N	rozkręcona tuleja prowadząca, brak przecieków	6.0	funkcjonalność
551	\N	funkcjonalność	w trakcie	\N	\N	ciasny gwint w przyłączu	6.0	funkcjonalność
621	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji	0.2	ogólne
595	\N	wyciek zewnętrzny	w trakcie	\N	\N	tarka na tłoczysku	2.0	wyciek zewnętrzny
251	Cylindro po próbach pozostają wypełnione olejem. Po wyciągnięciu z pieca na malarni, wycieka z nich olej	Wkręcanie za mocno/za słabo wkrętarką	zakonczone	M	P	\N	\N	\N
597	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	uszkodzone tłoczysko, woda po szlifie lub polerce	4.1	uszkodzenia mechaniczne
598	\N	uszkodz. uszczelnień montaż	w trakcie	\N	\N	uszkodzona uszczelka, brak paska na tłoku	3.1	przeciek wewnętrzny
74	Produkcja audytów wewnętrznych: tak, ale nie zostały zrealizowane na czas, a zatem nie ma zaktualizowanych terminów	Brak systematycznego raportowania i realizacji działań korygujących przez Kierowników poszczególnych działów.	w trakcie	\N	\N	\N	\N	\N
601	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, rowki na tłoczysku	0.2	ogólne
603	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, sprawny	0.2	ogólne
617	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	obite tłoczysko	4.1	uszkodzenia mechaniczne
75	W procesie produkcji dla części nie są zdefiniowane żadne punkty magazynowania.	Etapy procesu produkcyjnego zdefiniowane są w procesie produkcyjnym w systemie oraz końcowo w harmonogramach montażu. Gotowe półfabrykaty znajdują się na rozdzielniach magazynowych gdzie są opisane, zlokalizowane i wydawane zgodnie z zasadą FIFO.	w trakcie	\N	\N	\N	\N	\N
334	Podczas prób siłowników wylatują szczątki ściśniętej uszczelki tłoka (ścina uszczelkę na tłoku)	Spirale wykonywane w starym programie, nieskutecznie.	zakonczone	M	P	\N	\N	\N
310	Żle ustawione ucha (niezgodnie z rysunkiem), za dużo smaru-wycieka z siłowników	Nowy pracownik, brak doświadczenia i umiejętności. Brak nadzoru i szkoleń.	zakonczone	M	P	\N	\N	\N
612	\N	uszkodz. uszczelnień montaż	w trakcie	\N	\N	ścięta uszczelka	3.1	przeciek wewnętrzny
606	\N	wyciek zewnętrzny	w trakcie	\N	\N	wyciek zewnętrzny, urwany tłok	2.0	wyciek zewnętrzny
630	\N	uszkodzone tłoczysko/nurnik	w trakcie	\N	\N	urwane tłoczysko	4.1	uszkodzenia mechaniczne
635	\N	konstrukcja	w trakcie	\N	\N	średnica sprężyny niedostosowana do obudowy	6.8	funkcjonalność
419	Ostre zakończenia gwintu	Niewłaściwa technologia	w trakcie	M	P	\N	\N	\N
133	Ostra krawędź gwintu-problem z montażem (16 szt wkręcane z młotkiem). Wióry między zwojami, brak obróbki w tulei prowadzącej, pierścień na wyjściu z gwintu.	Niewłaściwa technologia/ Pracownicy nie zwrócili uwagi	w trakcie	M	P	\N	\N	\N
607	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, 1 szt. uszkodzony zawór	0.2	ogólne
609	\N	spoina korpus	w trakcie	\N	\N	spoina korpus	2.12	wyciek zewnętrzny
631	\N	siłownik nieweryfikowany, znaczny upływ gwarancji	w trakcie	\N	\N	po gwarancji, rozkręcany przez klienta	0.2	ogólne
411	Krzywo przyspawane korpusy	Spawa napędzane od strony korpusu i może dojśc do przesunięcia, które widać dopwieo  przy spawaniu króćca. 	w trakcie	M	P	\N	\N	\N
449	Rozbierzność wymiarów, w opisówce z rysunkiem (op 20- dotyczy otworu M8-6H), 	Nieuwaga pracownika	zakonczone	M	P	\N	\N	\N
176	Ostra krawędź spirali	Niewałściwy program	zakonczone	M	P	\N	\N	\N
465	Korozja od razu po myciu na montażu	Brak użycia konserwantu i przestrzegania instrukcji odnośnie postępowania z żeliwem. W przypadku obróbki żeliwa, należy zwiększyć stężenie chłodziwa na maszynie, następnie zanurzyć i przytrzymać chwilę detal dodatkowo w konserwancie.	zakonczone	M	P	\N	\N	\N
295	Spirale bez obróbki, wióry, ostre krawędzie	Zbyt głęboko wykonane spirale, pracownik nie trzymał wymiaru. Nie zgłaszano na bieżąco	zakonczone	M	P	\N	\N	\N
107	Na nowo dostarczonych siłownikach stwierdzono uszkodzona smarowniczke.	Uszkodzona uszczelka, tłok i cylinder.	w trakcie	\N	\N	\N	\N	\N
117	Uszkodzona uszczelka, tłok i cylinder.	Uderzenie smarowniczką podczas pakowania (przemęczenie, gabaryt), Uszkodzenie podczas pakowania (układanie na posadzce- brak odpowiedniego oprzyrządowania)	w trakcie	\N	\N	\N	\N	\N
620	\N	malarnia	w trakcie	\N	\N	wady powłoki lakierniczej, zbyt szybkie nałożenie folii	7.0	malarnia
294	8 szt bez frezowania, 2 szt z frezowaniem, zmiana wprowadzona bez karty zmian.	Poprawa funkcjonalności wyrobu, pośpiech konstruktora.	w trakcie	M	P	\N	\N	\N
563	\N	malarnia	w trakcie	\N	\N	niewłaściwy odcień farby	7.0	malarnia
409	Przesunięty otwór smarowniczki względem środka ucha	Żle powiercone- zły kąt. Nie ma odpowiedniego przyrządu.	zakonczone	M	P	\N	\N	\N
632	\N	zespół zasilający	w trakcie	\N	\N	wyciek spod dwuzłączki	2.4	wyciek zewnętrzny
163	Uszkodzona powierzchnia podczas wciskania nurników	Problem z przyrządem	zakonczone	M	P	\N	\N	\N
623	\N	cechowanie	w trakcie	\N	\N	niewłaściwa cecha	6.9	funkcjonalność
275	Nie zatwierdzono kart zmian 35/24 i 36/24. Zmieniono wymiary tłoka, bez zmiany pozostałych elementów- tłoczysko wpada na 4 mm.	Zmiana dotyczyła innych siłowników, TTK czekała na całościową zmianę we wszytskich cylindrach.	w trakcie	M	P	\N	\N	\N
152	W uchach zmontowanych siłowników znajdują się zanieczyszczenia, wióry po frezowaniu. Nie były myte. Montowanie łozysk w złozonych siłownikach (bardzo cięzkich)	Niewłaściwie myte.	zakonczone	M	P	\N	\N	\N
425	EXPOM> Brak informacji o zabezpieczeniu tłoka. W tłokach jest otwór pod wkręt- brak obróbki, ostre krawędzie; wkrętów nie wytano z magazynu (II zmiana), brak infromacji o nich w dokumentacji. Tuleje prowadzące się zacierają (wymiar do obniżenia). 1 szt zatarta, 1 szt na siłę wkręcona. 	Nieuwaga/ nie zadziałała kontrola	zakonczone	M	P	\N	\N	\N
356	Znaczne przecieki na rurce, dziury w spoinach.	Zamówiono niewłaściwą rurkę zasilającą przez zaopatrzenie (cynkowana a nie powinna być)	zakonczone	M	P	\N	\N	\N
432	Ostra spirala, zadziory/ nie wykonanie operacji honowania/problem ze spawaniem korpusu.	Spirala powinna być wykonywana płytką promieniową/ nie wykonano honowania, zamiast tego operację polerowania- nie usunięto zadziorów na spirali/ spawania króćców przed korpusem stwarza problemy z brakiem miejsca	zakonczone	P	P	\N	\N	\N
234	Notoryczne (ok 10 dziennie) odpryski w gwincie M10x1,5 pod smarowniczkę 	Brak osłonek, spawanie ręczne.	w trakcie	M	P	\N	\N	\N
313	Brak aktualizacji informacji na rysunku odnośnie cechowania (Unia wymaga jedynie nazwy i daty, rysunek sugeruje WTO)	Stary rysunek, nie szło od dawna. 	w trakcie	M	P	\N	\N	\N
397	Nieaktualny rysunek na stanowisku z data 14.02.2013 nie zgodny z dołączoną opisówką. Właściwy rysunek na sieci z dnia 15.12.2024- otwarcie zlecenia 19.11.2024. program do nieaktualnego rysunku	Brak KZ	zakonczone	P	P	\N	\N	\N
233	Cylinder dla Expom a na rysynku cechowanie do Uni Grudziąc	Stary rysunek, nie szło od dawna. Zmiana klienta	zakonczone	M	P	\N	\N	\N
302	Cylindry do Volant jednoznacznych informacji odnośnie cechowania	Stary rysunek, nie szło od dawna. Zmiana klienta	w trakcie	M	P	\N	\N	\N
398	Brak łozysk/ zgarniacz nachodzi na spoinę- wystaje 2mm poza tuleję prowadzącą 	Nie było łożysk na stanie/ Za szeroka spoina o 2mm, rysunek nie podaje max szerokości spoiny	zakonczone	M	P	\N	\N	\N
420	Początek i wyjście gwintu są ostre, wióry i zadziory.	Brak wykonanej obróbki po frezowaniu. Na podstawie KZ 74/24 16.12.24 wydłużono gwint, oraz dodano operację frezowania i obróbki. Zlecenie otwarto 05.12.24, zaktualizowano jedynie rysunek bez opisówki. 	zakonczone	P	P	\N	\N	\N
605	\N	spoina przyłącze	w trakcie	\N	\N	spoina przyłącze odpowietrzające	2.11	wyciek zewnętrzny
389	Odwrotnie zamontowane zawory	Nowy pracownik, brak doświadczenia i umiejętności.	zakonczone	M	P	\N	\N	\N
577	\N	uszkodzenia mechaniczne	w trakcie	\N	\N	uszkodzony pasek prowadzący	4.0	uszkodzenia mechaniczne
616	\N	uszkodzenia mechaniczne	w trakcie	\N	\N	zgięte ucho w obudowie, obity nurnik	4.0	uszkodzenia mechaniczne
560	\N	spoina przyłącze	w trakcie	\N	\N	spoina przyłącze	2.11	wyciek zewnętrzny
615	\N	uszkodzenia mechaniczne	w trakcie	\N	\N	urwana smarowniczka	4.0	uszkodzenia mechaniczne
613	\N	spoina przyłącze	w trakcie	\N	\N	spoina małe przyłącze	2.11	wyciek zewnętrzny
174	6+13 szt ciasny kanałek pod pasek fi 95H8 (jest 95,2). 2 szt ciasny gwint.	Nie wypełnienie kart kontrolnych.	zakonczone	M	P	\N	\N	\N
633	\N	uszkodzenia mechaniczne	w trakcie	\N	\N	urwany zawór	4.0	uszkodzenia mechaniczne
129	Otwory nie są przewiercone przelotowo. Problem z wiertłem?	Nieuwaga pracownika	zakonczone	M	P	\N	\N	\N
273	Liczne dziury po chromie.	Prawdopodobnie wstępna korozja, duże zlecenie za długo czekało do szlifu.	zakonczone	P	G	\N	\N	\N
490	Brak obróbki (pod drut), ostre krawędzie, wióry.	Brak odpowiednich narzędzi, nieuwaga pracowników.	w trakcie	M	P	\N	\N	\N
600	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek wewnętrzny, pęknięty tłok	3.0	przeciek wewnętrzny
592	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek wewnętrzny, brak o-ringa pod tłokiem	3.0	przeciek wewnętrzny
555	\N	przeciek wewnętrzny	w trakcie	\N	\N	uszkodzona uszczelka na tłoku	3.0	przeciek wewnętrzny
596	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek wewnętrzny, zdarty tłok	3.0	przeciek wewnętrzny
324	Brak obróbki otworów na kalamitki. W 2 szt. "bolec" nie wchodzi do ucha	Brak operacji obróbki w korpusach/ Nie zadziałała kontrola	zakonczone	M	P	\N	\N	\N
578	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek na tłoku	3.0	przeciek wewnętrzny
564	\N	przeciek wewnętrzny	w trakcie	\N	\N	rysy w obudowie i na tłoku	3.0	przeciek wewnętrzny
628	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek wewnętrzny	3.0	przeciek wewnętrzny
610	\N	przeciek wewnętrzny	w trakcie	\N	\N	rysy w obudowie	3.0	przeciek wewnętrzny
618	\N	przeciek wewnętrzny	w trakcie	\N	\N	przeciek wewnętrzny, spoina tłok	3.0	przeciek wewnętrzny
369	Sprawdzane cylindry z magazynu po zgłoszeniu reklamacyjnym. Nieogratowane, metalowe opiłki powciskane w tulejach i tłokach, w środku brud, śrut, zanieczyszczenia, ostre krawędzie w przyłączu.	Detale nie zostały umyte, nie zstały sprawdzone na próbach.	zakonczone	M	P	\N	\N	\N
301	Sprawdzane cylindry z magazynu po zgłoszeniu reklamacyjnym. Nieogratowane, metalowe opiłki powciskane w tulejach i tłokach, w środku brud, śrut, zanieczyszczenia, ostre krawędzie w przyłączu.	Detale nie zostały umyte, nie zostały sprawdzone na próbach.	zakonczone	M	P	\N	\N	\N
197	"Zagniecione" końce gwintów.	Niewłaściwy program/ Nieuwaga pracownika	zakonczone	M	P	\N	\N	\N
194	Przesunięcie otworu na przyłącze wzg. Osi otworu na korpusie.	Nieprawidłowo wykonane trasowanie przy stanowisku KJ.	zakonczone	P	P	\N	\N	\N
121	Brak szczelności na uszczelnieniu siłownika.	Uszkodzona uszczelka i zgarniacz podczas montażu.	w trakcie	\N	\N	\N	\N	\N
90	Brak szczelności zaworu w kierunku zamkniętym.	Uszkodzona uszczelka, tłok i cylinder.	w trakcie	\N	\N	\N	\N	\N
231	Ostra krawędź wewnętrzna (spiala). 	Niewłaściwa technologia	zakonczone	P	P	\N	\N	\N
105	Brak szczelności wewnętrznej.	Uszkodzona uszczelka, tłok i cylinder.	w trakcie	\N	\N	\N	\N	\N
529	Uszkodzenia mechaniczne, dziury, nieszczela powłoka galwaniczna.	Łożysko uszkadza chrom tłoczyska.	zakonczone	P	P	\N	\N	\N
509	Błąd w specyfikacji. Króciec wkręcany M12 posiada uszczelnienie a jest wpisana dodatkowo wkładka uszczelniająca	Błąd w technologi	zakonczone	M	P	\N	\N	\N
154	Brak obróbki po spawaniu rurki. Duże odpryski. Goldhoffer.	Niewłaściwe zabezpieczenie przed spawanie.	zakonczone	M	P	\N	\N	\N
213	Przesunięcie z osi otworów M10x1. Przesunięcie z osi toczonej średnicy fi 90 (-0,03,-0,06)	Nieuwaga pracownika	zakonczone	P	P	\N	\N	\N
552	\N	asortyment sprawny, reklamacja niezasadna	w trakcie	\N	\N	sprawny gwint, brak przecieku	0.0	ogólne
604	\N	asortyment sprawny, reklamacja niezasadna	w trakcie	\N	\N	sprawny, po gwarancji	0.0	ogólne
602	\N	asortyment sprawny, reklamacja niezasadna	w trakcie	\N	\N	sprawny	0.0	ogólne
593	\N	uszkodzony o-ring	w trakcie	\N	\N	za mały o-ring, rozerwany	2.3	wyciek zewnętrzny
95	Cylinder nieszczelny na zgarniaczu/uszczelce.	Uszkodzone uszczelnienie główne.	w trakcie	\N	\N	\N	\N	\N
96	Cylinder nieszczelny na zgarniaczu/uszczelce.	Niewłaściwy montaż uszczelnienia głównego.	w trakcie	\N	\N	\N	\N	\N
587	\N	uszkodzony o-ring	w trakcie	\N	\N	uszkodzony o-ring	2.3	wyciek zewnętrzny
575	\N	asortyment sprawny, reklamacja niezasadna	w trakcie	\N	\N	sprawne	0.0	ogólne
114	Cylinder nieszczelny na zgarniaczu/uszczelce.	Założenie konstrukcyjne sprawia problem montażowy, który może powodować ścinanie pierścienia oporowego. Powstały wiór może powodować przeciek gdy pozostanie w kanałku pomiędzy uszczelką a obudową.	w trakcie	\N	\N	\N	\N	\N
206	Zadziory w otworach przyłącza.	Niewłaściwa technologia, brak obróbki.	w trakcie	M	P	\N	\N	\N
260	Pominięty proces mycia. Detale spawane bez osłonek.	Wózkowy nie zawiózł detali do mycia, tylko bezpośrednio na montaż.	zakonczone	M	P	\N	\N	\N
499	Zadziory przy wyjściu gwintu w otworze oraz wiór spiralny	Pracownicy nie zwracają uwagi, niewłaściwe dobrana technologia	w trakcie	M	P	\N	\N	\N
201	Korozja na gwintach w tłoczysku. Odpryski w przyłączu.	Detale nie byyły myte przed spawaniem. Przyczyna korozji nie została ustalona	zakonczone	M	P	\N	\N	\N
85	Cylinder nieszczelny na zgarniaczu/uszczelce.	Cylinder nieszczelny po przez zadrgania w kanałku uszczelki głównej.	w trakcie	\N	\N	\N	\N	\N
417	Wióry w przyłączach	Brak mycia przed spawaniem	zakonczone	M	P	\N	\N	\N
361	Kruszący się początek zwoju gwintu po azotowaniu	Niewłaściwa technologia	zakonczone	M	P	\N	\N	\N
226	Odpryski w przyłączach	Nie było zaslepek/ Pracownicy nie zwrócili uwagi	zakonczone	M	P	\N	\N	\N
102	Cylinder nieszczelny na uszczelce	Uszkodzona uszczelka główna przez wiór metalowy.	w trakcie	\N	\N	\N	\N	\N
82	Cylindry nieszczelne na spoinach.	Przecieki na otworach technologicznych w przyłączu.	w trakcie	\N	\N	\N	\N	\N
87	Brak tulejki.	Brak tulejek ślizgowych w obudowie cylindra.	w trakcie	\N	\N	\N	\N	\N
88	Brak łożysk ślizgowych 2820BS w uchu tłoczyska.	Łozyska ślizgowe nie zostały zamontowane w 2 szt siłowników	w trakcie	\N	\N	\N	\N	\N
118	Smarowniczka w uchu tłoczyska z niewłaściwej strony GA447 	Błąd konstrukcyjny. Rysunki wykonawcze inne niż ofertowy.	w trakcie	\N	\N	\N	\N	\N
115	Siłownik nieszczelny na spoinie	Niewłaściwe wykonana spoina. Brak zakładki spoiny. Brudne elementy spawane i powstanie pęcherza gazowego. Niewykrycie przecieku.	w trakcie	\N	\N	\N	\N	\N
103	Smarownicza zamontowana po niewłaściwej stronie	Brak przyrządu. Nieuwaga pracownika. Brak dokumentacji na stanowisku spawalniczym. Brak kontroli nad spawaczem. 	w trakcie	\N	\N	\N	\N	\N
543	Wycieki oleju spod tulei prowadzącej na malarni	niedokręcone? 	w trakcie	M	P	\N	\N	\N
63	Nie jest jasne, kto i gdzie sprawdza wyniki malowania.	Kontroler Jakości z powodu przeprowadzanego audytu, nie zdąrzył podpisać dokumentów, natomiast spakowane palety zostały wywiezione na magazyn wyrobów gotowych, z powodu braku miejsca na ich przechowywanie na terenie Malarni. Kontroler miał je podpisać zaraz po audycie.	w trakcie	\N	\N	\N	\N	\N
64	Brak udokumentowanych wyników kontroli starych części w obszarze obróbki	Posiadamy w swoim asortymencie tysiące siłowników oraz części i nie jesteśmy w stanie wprowadzić oznaczeń we wszystkich rysunkach jednocześnie	w trakcie	\N	\N	\N	\N	\N
65	Codzienna kontrola oleju przez urządzenie testowe na końcu linii NIE sprawdzana codziennie, zgodnie z opisem	W wyjątkowych sytuacjach (nawał pracy, absencje pracowników, awarie itp.) zdarzają się dni bez kontroli. Staramy się jednak aby do takich wydarzeń nie dochodziło za często.	w trakcie	\N	\N	\N	\N	\N
67	Nie rozpoczęło się dochodzenie w sprawie wewnętrznych części NOK z zeszłego tygodnia (arkusz Excel).	Audyt odbywał się w poniedziałek, natomiast niezgodności z końca tygodnia nie zostały rozpoczęte, ponieważ miały się odbyć w dniu audytu.	w trakcie	\N	\N	\N	\N	\N
69	Maszyna nr 1593 do dziennego, tygodniowego, miesięcznego i 6-miesięcznego harmonogramu konserwacji nieudokumentowana	Brak systematycznej konroli maszyn pojedyńczych pracowników.	w trakcie	\N	\N	\N	\N	\N
72	Tak, ale niektóre dane nie są jeszcze kompletne, więc nie wiadomo, czy cele zostały osiągnięte, czy nie ( 2 z 3 bez faktycznej aktualizacji)	Brak systematycznego przekazywania informacji o stopniu realizacji celów jakościowych, przez Kierowników poszczególnych działów.	w trakcie	\N	\N	\N	\N	\N
76	Roszczenia nie są bezpośrednio związane z aktualnym statusem, działania naprawcze są zorientowane na (daleką) przyszłość. Brakuje czynnika obecnego czasu.	Działania skierowane na bliską przyszłość były skierowane na szkolenia i pouczanie pracowników i Mistrzów Produkcji. Nie zostały one ujmowane w prezentowanych raportach.	w trakcie	\N	\N	\N	\N	\N
73	Istnieje przegląd niezgodności wewnętrznych, ale nie zawsze jest on śledzony i nie zawsze zawiera jasne działania naprawcze.	Brak systematycznego raportowania i realizacji działań korygujących przez Kierowników poszczególnych działów.	w trakcie	\N	\N	\N	\N	\N
62	Prototypy znajdują się w nieoznaczonym miejscu	Nieoznakowane detale były wycofane z produkcji	w trakcie	\N	\N	\N	\N	\N
35	Operacja nr 10 (Próby Kontrolne) w Tłoczysku kompletnym R-375/2006 nie została wykonana. Po wciśnięciu tłoka detale zostały przetransportowane od razu na produkcję. Dotychczas, przed pakowaniem Tłoczyska R-375/2006 na Produkcji, tłoczyska zawsze były kontrolowane na prasie hydraulicznej na montażu zgodnie z Przewodnikiem i opracowaną dokumentacją technologiczną w postaci opisówki. Nie wykonanie prób może skutkować późniejszymi reklamacjami.	Według Kierownika PP Brak możliwości wykonania operacji nr 10 z powodu wyłączonej z eksploatacji prasy hydraulicznej dedykowanej do wykonania w/w czynności.	w trakcie	G	P	\N	\N	\N
101	Uszkodzona uszczelka główna przez wiór z tworzywa sztucznego powstały podczas wkładania pierścienia oporowego usczelki głównej.	Założenie konstrukcyjne sprawia problem montażowy, który może powodować ścinanie pierścienia oporowego. Powstały wiór może powodować przeciek gdy pozostanie w kanałku pomiędzy uszczelką a obudową.	w trakcie	\N	\N	\N	\N	\N
61	Roszczenia nie są bezpośrednio związane z aktualnym statusem, działania naprawcze są zorientowane na (daleką) przyszłość. Brakuje czynnika obecnego czasu.	Działania skierowane na bliską przyszłość były skierowane na szkolenia i pouczanie pracowników i Mistrzów Produkcji. Nie zostały one ujmowane w prezentowanych raportach.	w trakcie	\N	\N	\N	\N	\N
583	\N	uszkodzony gwint przyłącza	w trakcie	\N	\N	uszkodzony gwint przyłącza	4.6	uszkodzenia mechaniczne
77	- Niektóre chemikalia nie są odpowiednio przechowywane lub oznakowane, słaba identyfikacja lub brak\njej wcale, patrz zdjęcia.\n- Niektóre beczki są przechowywane bez "zbiornika zbiorczego" pod nimi.\n- Karty\ncharakterystyki nie są zgodne z najnowszą aktualizacją przepisów.	W trakcie audytu przedstawiono wyciągi z kart charakterystyk substancji chemicznych sporządzone na podstawie aktualnie obowiązujących kart. Nieaktualna była wyłącznie podstawa prawna na podstawie której sporządza się karty.	w trakcie	\N	\N	\N	\N	\N
561	\N	ostra krawędź, ścięcie uszczelnienia	w trakcie	\N	\N	odprysk po spawaniu, ścięta uszczelka	3.17	przeciek wewnętrzny
93	Siłownik nieszczelny wewnętrznie GA054	Przeciek wewnętrzny w siłowniku.\nSiłownik po gwarancji.	w trakcie	\N	\N	\N	\N	\N
97	Uszkodzona powłoka chromu GA512	Uszkodzona powłoka chromu przez kontakt z tuleją prowadzącą. Błędnie dobrana tuleja prowadząca do obciążeń bocznych (obudowa mocowana na sztywno).\nSiłownik po gwarancji.	w trakcie	\N	\N	\N	\N	\N
161	Brak chromu przy końcówkach tłoczyska (gotory materiał). Zauważono dopiero na malarni na spakowanych już cylindrach.	Żaden pracownik nie zauważył niezgodności	w trakcie	M	P	\N	\N	\N
86	 Wyciek na spoinie króćca.\nBrak siłownika do analizy ze względu na koszty transportu.	Prawdopodobnie szczelina była zaślepiona przez żużel który wykruszył się w trakcie eksploatacji. Może to tłumaczyć brak detekcji w Agromet oraz na pierwszym montażu w Aebi-Schmidt.	w trakcie	\N	\N	\N	\N	\N
106	Siłownik nieszczelny na spoinie GA421	Niewykrycie przecieku podczas próby.	w trakcie	\N	\N	\N	\N	\N
113	Uszkodzona powłoka chromu GA520	Uszkodzona powłoka chromu prawdopodobnie podczas polerowania.	w trakcie	\N	\N	\N	\N	\N
431	Na zwykłaej wiertarce nie ma możliwości uzyskać chorpowatości na posiomie Ra-1,6.	Nie dostosowanie wymagań technicznych do zapewnionych narzedzi	\N	P	P	\N	\N	\N
84	 Zerwane połączenie gwintowe pomiędzy tłokiem a tłoczyskiem.	Ze zdjęć od klienta widać, że został użyty klej do zabezpieczenia tłoka przez odkręceniem (zielone zabarwienie na wyjściu z gwintu i gwincie). Gwint zerwany na tłoczysku od połowy. Prawdopodobnie tłok odkręcił się do połowy tłoczyska w skutek eksploatacji po czym połączenie zostało zerwane. Drugą sytuacją mało prawdopodobną jest nieprawidłowo wykonany gwint w tłoku. Sytuacja niedokręconego tłoka jest niemożliwa ze względu na przelew wewnętrzny oraz wymiary siłownika (minimalny wymiar pomiędzy uszami siłownika byłby większy).\nBrak siłownika do analizy ze względu na koszty transportu.	w trakcie	\N	\N	\N	\N	\N
204	Niewłaściwie wykonana obróbka otworu fi 42 w obudowie. Zadziory, tnie tulejkę ślizgową	Nie wykonanie dokładnej obróbki. Zadziory powinny zostać usunięte po spawaniu, otwór powinien być fazowany.	w trakcie	M	P	\N	\N	\N
403	Liczne przecieki na rurkach	Niewłaściwie spawane. Brak WPS, nie można zaobserwować gołym okiem.	w trakcie	M	P	\N	\N	\N
236	Otwory w osi tłoczyska, lecz przesunięte z osi ucha. Niektóre sztuki przesunięte w obu miejscach, część zmontowana część na rozdzieli.	Źle zamocowane w przyrządzie, nie sprawdzane	w trakcie	M	P	\N	\N	\N
109	Wady ucha. Pękają. GA660	Ucha w siłownikach sprawne. Zostały w nie wciśnięte sprężyste tuleje redukcyjne u odbiorcy. Wpływ tulei redukcyjnych na ucha podczas pracy nieznane.	w trakcie	\N	\N	\N	\N	\N
120	Niewłaściwy wymiar tulejki. GA482	Zmiana konstrukcyjna na podstawie wymiany e-maili bez potwierdzenia ofertowego.	w trakcie	\N	\N	\N	\N	\N
614	\N	ingerencja użytkownika w wyrób, rozkręcanie itp.	w trakcie	\N	\N	ingerencja w wyrób, spalona uszczelka	0.1	ogólne
608	\N	ingerencja użytkownika w wyrób, rozkręcanie itp.	w trakcie	\N	\N	rozcięty cylinder, rowki na tłoczysku	0.1	ogólne
132	Tępa płytka do fazowania.	Pracownik nie zauwazył, nie sprawdzał dokładnie detali	zakonczone	M	P	\N	\N	\N
269	Liczne dziury na całej powierzchni tłoczyska	Krzywe, graniaste pręty.	zakonczone	P	G	\N	\N	\N
406	Skorodowane tłoczysko dwa dni po szlifowaniu (wysyłane do azotowania)	Nie zastosowano konserwantu, skorodowano pod folią. 	w trakcie	P	P	\N	\N	\N
500	Brak kanałka pod uszczelkę 1 szt, ciasne gwinty 20 szt	Pracownik nie dokonywał pomiarów detali	zakonczone	M	P	\N	\N	\N
584	\N	wiór	w trakcie	\N	\N	wiór pod uszczelką	2.21	wyciek zewnętrzny
556	\N	uszkodz. uszczelnień montaż	w trakcie	\N	\N	uszkodzony pasek oporowy przy montażu	2.22	wyciek zewnętrzny
570	\N	uszkodz. uszczelnień ostra krawędź	w trakcie	\N	\N	źle wykonany kanałek pod uszczelkę, ostre krawędzie	2.23	wyciek zewnętrzny
127	W operacji toczenia nr 10 wpisano niewłaściwy nr sprawdzianu do kanałka szer. 10,2- AMA 8319; powinno być SMS- 15642.	Pomyłka pracownika TTK	zakonczone	P	P	\N	\N	\N
336	Znaczna tarka, w porę zauważona na chromowni.	Krzywe, graniaste pręty.	zakonczone	G	G	\N	\N	\N
444	prośba o zmianę tolerancji na wykonanie otworu fi 63 (+0,06;+0,03) na fi 63 (+0,08; +0,05), ze względu na tłoczysko, które będzie robione z gotowca.	Gotowy materiał posiada wyższe wymiary niż chromowany na miejscu.	w trakcie	P	P	\N	\N	\N
590	\N	uszkodzone tłoczysko, nurnik	w trakcie	\N	\N	obicia na nurniku powstałe u klienta	2.27	wyciek zewnętrzny
558	\N	uszkodzone tłoczysko, nurnik	w trakcie	\N	\N	wyciek zewnętrzny, uszkodzone tłoczysko	2.27	wyciek zewnętrzny
237	Dziury w chromie w całej serii. Licznie występujące na całej powierzchni.	Zastosowanie wyeksploatowanej wanny do chromowania.	zakonczone	G	G	\N	\N	\N
534	Uszkodzone tłoczyska do Zollera- mechanicznie 	Niewłaściwa obróbka ślusarska przez niedoświadczonego pracownika.	zakonczone	M	P	\N	\N	\N
540	Wióry w przyłączach	Nie wykonanie właściewej obróbki przez pracownika	zakonczone	M	P	\N	\N	\N
353	Wydano nieodpowiednie zawory do cylindrów, które zostały zamontowane.	Wysłanie przez dostawcę nieodpowiednich zaworów, niedoświadczony pracownik przyjął na stan.	w trakcie	M	P	\N	\N	\N
245	Znaczne problemy z montażem siłownika, wywołane przez zmianę uszczelki na tłoku. Montąż wymaga znacznej siły, pracownicy nie radzą sobie z wykonaniem.	Użycie podstawowej uszczelki a nie zamiennika, jak było dotychczas	w trakcie	M	P	\N	\N	\N
108	 Hałas podczas pracy siłowników.	 Brak pasty montażowej w tulei prowadzącej. Montaż siłowników 11/2024 przed wprowadzeniem instrukcji obrazkowej.	w trakcie	\N	\N	\N	\N	\N
125	Różnice pomiędzy rysunkiem ofertowym a wykonawczym	??????	w trakcie	M	P	\N	\N	\N
223	Błąd pracownika przy osadzaniu tłoka na gorąco. Wymiar 289 (0;-0,2) wykonano na plusie do +0,13. Wymiar całościowy 600 (-0,1;-0,4) wykonano w minusie do -0,52.	Zepsuty piec na hartowni, osadzanie w narzedziowni, gdzie były problemy z ustaleniem idealnej temperatury.	w trakcie	P	P	\N	\N	\N
94	Do weryfikacji – przeciek wewnętrzny	Brak możliwości sprzętowej i infrastrukturalnej do montażu siłowników w innej pozycji niż w poziomie. Nie sprawdzony przeciek wewnętrzny- sprawdzane losowe wg. WTO.	w trakcie	\N	\N	\N	\N	\N
170	Półpierścień nie wchodzi w kanałek	Niewłaściwa technologia	zakonczone	M	P	\N	\N	\N
81	Uszkodzona powłoka lakiernicza w siłowniku GA453	Niedokładne malowanie krawędzi.	w trakcie	\N	\N	\N	\N	\N
83	Siłownik nieszczelny na spoinie GA588	Siłownik sprawny. Próba nie wykazała nieszczelności.	w trakcie	\N	\N	\N	\N	\N
91	Uszkodzona powłoka lakiernicza w siłowniku GA454	Niedokładne malowanie krawędzi.	w trakcie	\N	\N	\N	\N	\N
92	Siłownik nieszczelny na spoinie GA517	Niewykrycie przecieku podczas próby.	w trakcie	\N	\N	\N	\N	\N
100	Uszkodzona powłoka chromu GA588	Uszkodzona powłoka chromu podczas montażu.	w trakcie	\N	\N	\N	\N	\N
104	Siłownik nieszczelny na spoinie GA588 	Niewykrycie przecieku.	w trakcie	\N	\N	\N	\N	\N
110	Smarowniczka w uchu tłoczyska z niewłaściwej strony GA447	Błąd konstrukcyjny. Rysunki wykonawcze inne niż ofertowy.	w trakcie	\N	\N	\N	\N	\N
111	Uszkodzona powłoka chromu GA512 	Uszkodzona powłoka chromu przez kontakt z tuleją prowadzącą. Błędnie dobrana tuleja prowadząca do obciążeń bocznych (obudowa mocowana na sztywno).	w trakcie	\N	\N	\N	\N	\N
112	Brak siłownika do weryfikacji pochodzenia wiórów. Kształt oraz długość wiórów nie pasuje do wiórów powstałych podczas eksploatacji siłownika. Miejsce ich wystąpienia (między dławnicą a tłokiem) nie pasują do możliwych miejsc powstania (brak mycia obudowy - wióry pomiędzy tłokiem a denkiem). Wielkość wiórów uniemożliwia dostanie się ich przez przyłącza. Ze względu braku dowodów nie ma możliwości przeprowadzenia analizy i podjęcia działań.	Błąd konstrukcyjny. Rysunki wykonawcze inne niż ofertowy.	w trakcie	\N	\N	\N	\N	\N
119	Siłownik nieszczelny na spoinie GA474	Niewykrycie przecieku podczas próby.	w trakcie	\N	\N	\N	\N	\N
576	\N	funkcjonalność	w trakcie	\N	\N	rysy na tłoczyskach	6.0	funkcjonalność
442	Korozja na gwintach zewnętrznych. Przed szlifowaniem należy oczyścić gwint.	Brak konserwantu, za małe stężenie chłodziwa (ok. 2%- powinno być powyżej 5, najleoiej w okolicach 6%) . Niewłaściwie rozrobione chłodziwo. Osoba odpowiedzialna za dolanie chłodziwa, nie sprawdziła stężenia.	zakonczone	P	P	\N	\N	\N
193	Brak podkładek. Brak dokręcania kluczem dynanometrycznym.	Brak nadzoru	zakonczone	M	P	\N	\N	\N
172	Za dłygie przyłącza oczkowe, nie można zmontować.	Różne długości rurek od dostawców, brak możliwości zamawiania jednego rozmiaru (nie można polegac na jednym dostawcy)	w trakcie	M	P	\N	\N	\N
147	Zoller uruchomienie. Pojedyńcze pory w chromie oraz punkty korozyjne. 	Niewłaściewe polerowanie przed chormowaniem	zakonczone	M	P	\N	\N	\N
135	Osłona z blachy nie gwarantuje pokrycia chromem całego tłoczyska. Brak chromu na tłoczysku będzie wchodził pod zgarniacze. 	Oprzyrządowanie przestarzałe, osłona nie spełnia swojej fukcji w wystarczającym zakresie.	zakonczone	M	P	\N	\N	\N
258	Pręt di 32,2h9 pomimo prostowania wychodzi krzywizna do 0,1 i bicie na końcach 0,8. Spowodowało to zatrzymanie roboty na II zmianie z braku możliwości utrzymania bicia na szyjce fi 25f7 -0,05 (l-537 mm). 	Błędy kształtu materiału	zakonczone	P	P	\N	\N	\N
191	Pręt di 32,2h9 pomimo prostowania wychodzi krzywizna do 0,1 i bicie na końcach 0,8. Spowodowało to zatrzymanie roboty na II zmianie z braku możliwości utrzymania bicia na szyjce fi 22 f7 -0,05 (l-516 mm)	Błędy kształtu materiału	zakonczone	P	P	\N	\N	\N
249	Brak zabezpieczeń na gwinty po spawaniu. Gdzie są zaślepki?	Brak nadzoru	zakonczone	M	P	\N	\N	\N
214	Znaczna ilość odprysków w obrębie przyłącza, również w gwincie wewnętrznym	Niewłaściwa kontrola- nie zadzałała niebieska karta.	w trakcie	M	P	\N	\N	\N
238	Nieprawidłowo zagniecione łozyska. Luźny gwint korpusu ucha. 	Wciskanie łozysk do zmontowanych siłowników- pośpiech, brak czasu, przyspieszony montaż. / Brak przepływu informacji- gwinty dopuszczono warunkowo na produkcji, 2msc wcześniej.	w trakcie	M	P	\N	\N	\N
309	Korozja, zanieczyszczenia na gwincie. Detale zatrzymane 20.02.25, rdza z gwintu miała być usuwana z gwintu po malowaniu- pomimo zaleceń Kierownika Jakości, aby zrobić to wcześniej. Po spakowaniu na malarni, zuwazono punkty korozyjne powyżej zabezpieczenia gwintu (gumowego kondoma). Po ściagnięciu okazało się że pod osłoną w wielu detalach również znajdują się punkty korozyjne- najczęsciej w górnej warstwie pod wcześniej założoną taśmą ochronna oraz nieusunięte kawałki papierowej taśmy. Detale miały wyjechać w dniu dzisiejszym do klienta. Sprawdzono również już spakowane siłowniki do wysyłki. One rówież zostały cofnięte do ponownej kontroli i oczyszczenia.	Brak konserwantu, za małe stężenie chłodziwa (ok. 2%- powinno być powyżej 5, najleoiej w okolicach 6%) . Niewłaściwie rozrobione chłodziwo. Osoba odpowiedzialna za dolanie chłodziwa, nie sprawdziła stężenia.	zakonczone	M	P	\N	\N	\N
372	Korozja, zanieczyszczenia na gwincie	Brak konserwantu, za małe stężenie chłodziwa. Niewłaściwie rozrobione chłodziwo	zakonczone	M	P	\N	\N	\N
363	Spawacze sygnalizują problem dotyczacy spawania z kostką prowadzącą. Przyrząd nie współgra ze spawaniem.	Problemy z przyrządem	zakonczone	P	P	\N	\N	\N
116	Odpryski w gwincie G1/4 oraz M20x1,5.  	Po przeanalizowaniu dostarczonych siłowników stwierdzamy, że źródłem problemu są odpryski spawalnicze. Podczas spawania elementów oddalonych od przyłączy lub zaślepiania otworów technologicznych spawacze nie używali osłon na przyłącza.	w trakcie	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5027 (class 0 OID 19133)
-- Dependencies: 230
-- Data for Name: opis_problemu_audyt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opis_problemu_audyt (opis_problemu_id, audyt_id) FROM stdin;
35	4
61	43
61	44
61	45
61	46
61	47
61	48
61	49
61	50
61	51
61	52
61	53
61	54
61	55
61	56
61	57
61	58
62	43
62	44
62	45
62	46
62	47
62	48
62	49
62	50
62	51
62	52
62	53
62	54
62	55
62	56
62	57
62	58
63	43
63	44
63	45
63	46
63	47
63	48
63	49
63	50
63	51
63	52
63	53
63	54
63	55
63	56
63	57
63	58
64	43
64	44
64	45
64	46
64	47
64	48
64	49
64	50
64	51
64	52
64	53
64	54
64	55
64	56
64	57
64	58
65	43
65	44
65	45
65	46
65	47
65	48
65	49
65	50
65	51
65	52
65	53
65	54
65	55
65	56
65	57
65	58
66	43
66	44
66	45
66	46
66	47
66	48
66	49
66	50
66	51
66	52
66	53
66	54
66	55
66	56
66	57
66	58
67	43
67	44
67	45
67	46
67	47
67	48
67	49
67	50
67	51
67	52
67	53
67	54
67	55
67	56
67	57
67	58
68	43
68	44
68	45
68	46
68	47
68	48
68	49
68	50
68	51
68	52
68	53
68	54
68	55
68	56
68	57
68	58
69	43
69	44
69	45
69	46
69	47
69	48
69	49
69	50
69	51
69	52
69	53
69	54
69	55
69	56
69	57
69	58
70	43
70	44
70	45
70	46
70	47
70	48
70	49
70	50
70	51
70	52
70	53
70	54
70	55
70	56
70	57
70	58
71	43
71	44
71	45
71	46
71	47
71	48
71	49
71	50
71	51
71	52
71	53
71	54
71	55
71	56
71	57
71	58
72	43
72	44
72	45
72	46
72	47
72	48
72	49
72	50
72	51
72	52
72	53
72	54
72	55
72	56
72	57
72	58
73	43
73	44
73	45
73	46
73	47
73	48
73	49
73	50
73	51
73	52
73	53
73	54
73	55
73	56
73	57
73	58
74	43
74	44
74	45
74	46
74	47
74	48
74	49
74	50
74	51
74	52
74	53
74	54
74	55
74	56
74	57
74	58
75	43
75	44
75	45
75	46
75	47
75	48
75	49
75	50
75	51
75	52
75	53
75	54
75	55
75	56
75	57
75	58
76	43
76	44
76	45
76	46
76	47
76	48
76	49
76	50
76	51
76	52
76	53
76	54
76	55
76	56
76	57
76	58
77	39
77	40
77	41
77	42
78	39
78	40
78	41
78	42
79	39
79	40
79	41
79	42
\.


--
-- TOC entry 5028 (class 0 OID 19136)
-- Dependencies: 231
-- Data for Name: opis_problemu_dzial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opis_problemu_dzial (opis_problemu_id, dzial_id) FROM stdin;
125	2
127	2
129	1
132	1
133	1
133	2
135	2
152	1
154	1
160	3
161	1
161	3
163	1
163	2
170	2
172	2
172	3
174	1
176	1
191	3
193	1
194	6
194	8
197	1
197	2
201	1
202	1
204	1
206	1
206	2
213	1
214	1
223	8
226	1
231	2
233	2
234	1
234	2
236	1
238	1
245	2
249	1
251	1
258	3
260	1
269	3
273	1
275	2
278	3
294	1
294	2
295	1
301	1
302	2
309	1
310	1
313	2
324	1
334	1
334	2
336	3
337	1
337	2
353	3
356	3
361	2
363	2
369	1
372	1
389	1
396	8
397	2
398	2
403	1
403	2
406	1
409	1
409	2
411	1
411	2
417	1
417	2
419	1
419	2
420	1
425	1
425	2
431	2
432	2
442	1
444	3
449	2
457	2
465	1
465	2
469	3
490	1
490	2
499	1
499	2
500	1
509	2
528	2
529	2
543	8
\.


--
-- TOC entry 5030 (class 0 OID 19140)
-- Dependencies: 233
-- Data for Name: opis_problemu_reklamacja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opis_problemu_reklamacja (opis_problemu_id, reklamacja_id) FROM stdin;
81	43
82	59
82	60
82	61
82	74
82	75
82	76
82	77
82	78
82	79
83	30
83	39
84	3
84	4
84	5
85	66
85	67
85	68
85	69
86	6
86	7
87	80
88	26
88	27
89	40
90	11
90	12
91	42
92	44
93	31
94	110
94	111
94	112
94	113
95	53
95	54
96	52
97	34
98	114
98	115
98	116
99	66
99	68
99	69
100	46
101	81
101	82
101	83
101	84
101	85
101	86
101	87
101	88
102	70
102	71
102	72
102	73
103	48
103	51
104	30
104	39
105	13
105	14
105	15
105	16
105	17
105	18
105	19
105	20
105	21
105	22
106	35
107	10
108	28
108	29
109	37
109	38
110	45
111	41
112	9
113	32
113	33
114	62
114	63
114	64
114	65
115	49
115	50
116	55
116	56
116	57
116	58
116	89
116	90
116	91
116	92
116	93
116	94
116	95
116	96
116	97
116	98
116	99
116	100
116	101
116	102
116	103
116	104
116	105
116	106
116	107
116	108
116	109
117	8
118	48
118	51
119	47
120	36
121	23
121	24
121	25
125	492
127	177
129	199
132	427
133	344
135	517
147	370
152	294
154	202
161	390
163	401
170	160
172	416
174	459
176	169
191	195
193	463
194	414
197	203
201	335
202	321
204	505
206	403
213	261
214	267
223	510
226	179
231	186
233	496
234	413
236	347
237	162
238	200
245	381
249	357
251	301
258	229
260	425
269	272
273	253
275	343
278	304
294	458
295	402
301	461
302	361
309	373
310	220
313	201
324	486
334	220
336	339
353	218
356	168
361	316
363	354
369	206
372	373
389	430
397	494
398	502
403	342
406	205
409	226
411	296
417	289
419	432
420	277
425	305
431	473
432	146
442	282
444	392
449	330
465	330
469	228
490	376
490	495
499	219
500	293
509	213
529	230
534	438
540	346
543	183
550	540
550	545
550	548
550	631
550	650
551	545
551	573
551	577
551	578
551	594
551	595
551	599
551	600
551	603
551	604
551	652
551	656
551	657
552	523
552	536
552	537
552	582
552	589
552	596
552	598
552	601
552	604
552	609
552	611
552	612
552	614
552	615
552	619
552	620
552	625
552	634
552	644
552	649
553	554
553	566
553	567
554	543
554	545
554	548
554	552
554	554
554	556
554	564
554	582
554	625
554	635
554	636
554	644
554	647
555	525
555	528
555	529
555	552
555	556
555	572
555	581
555	582
555	625
555	638
555	644
555	647
555	651
556	608
557	556
557	573
558	588
558	610
559	539
559	589
559	616
559	632
560	526
560	530
560	570
560	576
560	613
560	623
560	624
560	639
561	655
562	538
562	579
562	589
562	625
562	630
562	641
563	535
563	641
564	525
564	528
564	529
564	552
564	556
564	572
564	581
564	582
564	625
564	638
564	644
564	647
564	651
565	538
565	579
565	589
565	625
565	630
565	641
566	545
566	573
566	577
566	578
566	594
566	595
566	599
566	600
566	603
566	604
566	652
566	656
566	657
567	548
567	556
567	582
567	593
567	597
567	602
567	607
567	621
568	545
568	573
568	577
568	578
568	594
568	595
568	599
568	600
568	603
568	604
568	652
568	656
568	657
569	556
569	573
570	618
571	545
571	573
571	577
571	578
571	594
571	595
571	599
571	600
571	603
571	604
571	652
571	656
571	657
572	548
572	556
572	582
572	593
572	597
572	602
572	607
572	621
573	538
573	579
573	589
573	625
573	630
573	641
574	548
574	556
574	582
574	593
574	597
574	602
574	607
574	621
575	523
575	536
575	537
575	582
575	589
575	596
575	598
575	601
575	604
575	609
575	611
575	612
575	614
575	615
575	619
575	620
575	625
575	634
575	644
575	649
576	545
576	573
576	577
576	578
576	594
576	595
576	599
576	600
576	603
576	604
576	652
576	656
576	657
577	527
577	543
577	565
577	569
577	580
577	653
578	525
578	528
578	529
578	552
578	556
578	572
578	581
578	582
578	625
578	638
578	644
578	647
578	651
579	545
579	573
579	577
579	578
579	594
579	595
579	599
579	600
579	603
579	604
579	652
579	656
579	657
580	548
580	556
580	582
580	593
580	597
580	602
580	607
580	621
581	548
581	556
581	582
581	593
581	597
581	602
581	607
581	621
582	543
582	545
582	548
582	552
582	554
582	556
582	564
582	582
582	625
582	635
582	636
582	644
582	647
583	658
584	617
584	643
585	541
585	542
585	629
586	548
586	556
586	582
586	593
586	597
586	602
586	607
586	621
587	524
587	561
587	563
587	568
587	575
587	622
587	654
588	545
588	573
588	577
588	578
588	594
588	595
588	599
588	600
588	603
588	604
588	652
588	656
588	657
589	561
589	672
590	588
590	610
591	538
591	579
591	589
591	625
591	630
591	641
592	525
592	528
592	529
592	552
592	556
592	572
592	581
592	582
592	625
592	638
592	644
592	647
592	651
593	524
593	561
593	563
593	568
593	575
593	622
593	654
594	545
594	573
594	577
594	578
594	594
594	595
594	599
594	600
594	603
594	604
594	652
594	656
594	657
595	548
595	556
595	582
595	593
595	597
595	602
595	607
595	621
596	525
596	528
596	529
596	552
596	556
596	572
596	581
596	582
596	625
596	638
596	644
596	647
596	651
597	538
597	579
597	589
597	625
597	630
597	641
598	554
598	566
598	567
599	545
599	573
599	577
599	578
599	594
599	595
599	599
599	600
599	603
599	604
599	652
599	656
599	657
600	525
600	528
600	529
600	552
600	556
600	572
600	581
600	582
600	625
600	638
600	644
600	647
600	651
601	543
601	545
601	548
601	552
601	554
601	556
601	564
601	582
601	625
601	635
601	636
601	644
601	647
602	523
602	536
602	537
602	582
602	589
602	596
602	598
602	601
602	604
602	609
602	611
602	612
602	614
602	615
602	619
602	620
602	625
602	634
602	644
602	649
603	543
603	545
603	548
603	552
603	554
603	556
603	564
603	582
603	625
603	635
603	636
603	644
603	647
604	523
604	536
604	537
604	582
604	589
604	596
604	598
604	601
604	604
604	609
604	611
604	612
604	614
604	615
604	619
604	620
604	625
604	634
604	644
604	649
605	526
605	530
605	570
605	576
605	613
605	623
605	624
605	639
606	548
606	556
606	582
606	593
606	597
606	602
606	607
606	621
607	543
607	545
607	548
607	552
607	554
607	556
607	564
607	582
607	625
607	635
607	636
607	644
607	647
608	633
608	637
609	539
609	589
609	616
609	632
610	525
610	528
610	529
610	552
610	556
610	572
610	581
610	582
610	625
610	638
610	644
610	647
610	651
611	545
611	573
611	577
611	578
611	594
611	595
611	599
611	600
611	603
611	604
611	652
611	656
611	657
612	554
612	566
612	567
613	526
613	530
613	570
613	576
613	613
613	623
613	624
613	639
614	633
614	637
615	527
615	543
615	565
615	569
615	580
615	653
616	527
616	543
616	565
616	569
616	580
616	653
617	538
617	579
617	589
617	625
617	630
617	641
618	525
618	528
618	529
618	552
618	556
618	572
618	581
618	582
618	625
618	638
618	644
618	647
618	651
619	545
619	573
619	577
619	578
619	594
619	595
619	599
619	600
619	603
619	604
619	652
619	656
619	657
620	535
620	641
621	543
621	545
621	548
621	552
621	554
621	556
621	564
621	582
621	625
621	635
621	636
621	644
621	647
622	545
622	573
622	577
622	578
622	594
622	595
622	599
622	600
622	603
622	604
622	652
622	656
622	657
623	531
624	561
624	672
625	640
626	545
626	573
626	577
626	578
626	594
626	595
626	599
626	600
626	603
626	604
626	652
626	656
626	657
627	570
628	525
628	528
628	529
628	552
628	556
628	572
628	581
628	582
628	625
628	638
628	644
628	647
628	651
629	617
629	643
630	538
630	579
630	589
630	625
630	630
630	641
631	543
631	545
631	548
631	552
631	554
631	556
631	564
631	582
631	625
631	635
631	636
631	644
631	647
632	532
632	533
632	534
633	527
633	543
633	565
633	569
633	580
633	653
635	541
635	542
635	629
\.


--
-- TOC entry 5031 (class 0 OID 19143)
-- Dependencies: 234
-- Data for Name: pracownik; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pracownik (id, imie, nazwisko, email, telefon, stanowisko, dzial_id) FROM stdin;
1	Jarosław	Bartoszko	j.bartoszko@zehs.com.pl	\N	\N	\N
2	Andrzej	Izdebski	a.izdebski@zehs.com.pl	\N	\N	\N
3	Radosław	Szczęsny	r.szczesny@zehs.com.pl	\N	\N	\N
4	Natalia	Terlecka	n.terlecka@zehs.com.pl	\N	\N	\N
5	Marta	Liput	m.liput@zehs.com.pl	\N	\N	\N
7	Tadeusz	Rakowski	t.rakowski@zehs.com.pl	\N	\N	\N
8	Paweł	Pleśnierowicz	p.plesnierowicz@zehs.com.pl	\N	\N	\N
9	Angelika	Michno	a.michno@zehs.com.pl	\N	\N	\N
12	Mieczysław	Dembowy	m.dembowy@zehs.com.pl	\N	\N	\N
13	Dariusz	Sudnik	d.sudnik,@zehs.com.pl	\N	\N	\N
14	Paweł	Zawadka	p.zawadka@zehs.com.pl	\N	\N	\N
15	Marcin	Pruchniewicz	m.pruchniewicz@zehs.com.pl	\N	\N	\N
16	Robert	Ogrodnik	r.ogrodnik@zehs.com.pl	\N	\N	\N
10	Marcin	Boroński	m.boronski@zehs.com.pl	\N	\N	\N
11	Edward	Dudziak	e.dudziak@zehs.com.pl	\N	\N	\N
17	Marek	Palczyński	m.palczyński@zehs.com.pl	\N	\N	\N
18	Krzysztof	Śmigiel	k.śmigiel@zehs.com.pl	\N	\N	\N
19	Remigiusz	Guła	r.guła@zehs.com.pl	\N	\N	\N
20	Artur	Łowicki	a.łowicki@zehs.com.pl	\N	\N	\N
21	Alfred	Kazan	a.kazan@zehs.com.pl	\N	\N	\N
22	Mariusz	Pilarski	m.pilarski@zehs.com.pl	\N	\N	\N
23	Tomasz	Mazurek	t.mazurek@zehs.com.pl	\N	\N	\N
\.


--
-- TOC entry 5033 (class 0 OID 19147)
-- Dependencies: 236
-- Data for Name: reklamacja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reklamacja (id, firma_id, typ_id, data_otwarcia, data_weryfikacji, "data_zakończenia", data_produkcji_silownika, nr_reklamacji, typ_cylindra, zlecenie, status, nr_protokolu, analiza_terminowosci_weryfikacji, dokument_rozliczeniowy, nr_dokumentu, data_dokumentu, nr_magazynu, nr_listu_przewozowego, przewoznik, analiza_terminowosci_realizacji) FROM stdin;
295	29	3	2024-09-05	\N	\N	\N	\N	\N	50641469	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	1	2	2025-04-14	\N	\N	\N	 2200030976	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	3	2	2025-04-14	\N	\N	\N	T250019446	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
34	3	2	2025-04-14	\N	\N	\N	T250009692	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
662	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123818.0	t	55/25	\N	\N	\N	\N	\N	\N	\N	\N
659	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123815.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
667	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123823.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
670	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123826.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
681	2	3	\N	\N	\N	\N	2200031034 	dsfds	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
674	79	1	2025-06-10	\N	\N	\N	RES/2025/03/6	Cylinder hydr.tłokowy	60123831.0	t	58/25	\N	\N	\N	\N	\N	\N	\N	\N
678	79	1	2025-06-10	\N	\N	\N	RES/2025/05/28	Cylinder hydr.tłokowy	60123835.0	f	58/25	\N	\N	\N	\N	\N	\N	\N	\N
677	79	1	2025-06-10	\N	\N	\N	RES/2025/04/4	Cylinder hydr.tłokowy	60123834.0	f	58/25	\N	\N	\N	\N	\N	\N	\N	\N
676	79	1	2025-06-10	\N	\N	\N	RES/2025/04/3	Cylinder hydr.tłokowy	60123833.0	f	58/25	\N	\N	\N	\N	\N	\N	\N	\N
679	79	1	2025-06-10	\N	\N	\N	RES/2025/05/32	Cylinder hydr.tłokowy	60123836.0	f	58/25	\N	\N	\N	\N	\N	\N	\N	\N
675	79	1	2025-06-10	\N	\N	\N	RES/2025/04/2	Cylinder hydr.tłokowy	60123832.0	f	58/25	\N	\N	\N	\N	\N	\N	\N	\N
673	35	1	2025-06-09	\N	\N	\N	079/2025/1003	Cylinder hydr.tłokowy	60123830.0	f	57/25	\N	\N	\N	\N	\N	\N	\N	\N
671	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123827.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
672	1	1	2025-06-05	\N	\N	\N	2200031446	Cylinder hydr.tłokowy	60123828.0	f	56/25	\N	\N	\N	\N	\N	\N	\N	\N
658	69	1	2025-06-02	\N	\N	\N	L10075949	Cylinder hydr.teleskopowy	60221843.0	f	54/25	\N	WZ	99319	\N	\N	\N	\N	\N
668	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123824.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
666	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123822.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
663	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123819.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
660	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123816.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
669	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123825.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
665	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123821.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
661	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123817.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
664	29	1	2025-06-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123820.0	f	55/25	\N	\N	\N	\N	\N	\N	\N	\N
657	58	1	2025-05-27	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123814.0	f	53/25	\N	WZ	99320	\N	\N	\N	\N	\N
656	81	1	2025-05-15	\N	\N	\N	\N	Cylinder hydr.teleskopowy	60123813.0	f	52/25	\N	WZ	99136	2025-05-28	2493	29312901822	DHL	10
655	1	1	2025-05-14	\N	\N	\N	2200031258	Cylinder hydr.tłokowy	60123812.0	f	51/25	\N	złom	ZW 20149	\N	\N	\N	\N	\N
654	27	1	2025-05-14	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123811.0	f	50/25	\N	WZ	99021	2025-05-16	2493	0000037698369T	DPD	3
5	1	2	2025-04-14	\N	\N	\N	2200031034 	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
653	86	1	2025-05-08	\N	\N	\N	LR-25/6526	Cylinder hydr.tłokowy	60123810.0	f	49/25	\N	\N	\N	\N	\N	\N	\N	\N
652	86	1	2025-05-08	\N	\N	\N	LR-25/6506	Cylinder hydr.tłokowy	60123809.0	f	49/25	\N	\N	\N	\N	\N	\N	\N	\N
651	1	1	2025-05-05	\N	\N	\N	2200031183	Cylinder hydr.tłokowy	60123808.0	f	48/25	\N	korekta	47/K/25	\N	\N	\N	\N	1
650	35	1	2025-04-28	\N	\N	\N	056/2025/1003	Cylinder hydr.tłokowy	60123807.0	f	47/24	\N	WZ	99118	2025-05-31	2493	\N	\N	25
649	72	1	2025-04-22	\N	\N	\N	QAM 15952	Cylinder hydr.nurnikowy	60221842.0	f	46/25/ zw 2494	\N	WZ	99008	2025-05-19	2494	PNT7448A	Firma spedycyjna	20
644	33	1	2025-04-22	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221840.0	f	44/25 zw 2494	\N	\N	\N	\N	\N	\N	\N	\N
647	33	1	2025-04-22	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221841.0	f	45/25 / zw 2494	\N	\N	\N	\N	\N	\N	\N	\N
643	80	1	2025-04-17	\N	\N	\N	NKJ/REK/25/010	Cylinder hydr.tłokowy	60123806.0	f	43/25	\N	WZ	99020	2025-05-16	2493	0000037698296T	DPD	22
390	9	3	2025-04-14	\N	\N	\N	\N	\N	50043811	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	1	2	2025-04-14	\N	\N	\N	 2200030976	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	3	2	2025-04-14	\N	\N	\N	T250005026	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	3	2	2025-04-14	\N	\N	\N	T250012903	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	3	2	2025-04-14	\N	\N	\N	T250012903	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
473	1	3	2025-04-14	\N	\N	\N	\N	\N	50942726	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	1	2	2025-04-14	\N	\N	\N	2200031034 	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	1	2	2025-04-14	2025-02-15	\N	\N	2200031034 	cylinder skokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	3	2	2025-04-14	\N	\N	\N	T250001911	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
505	45	3	2025-04-11	\N	\N	\N	\N	\N	50043723	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
641	86	1	2025-04-11	\N	\N	\N	LR-25/6404	Cylinder hydr.tłokowy	60123805.0	f	42/25 TŁOCZYSKO	\N	\N	\N	\N	\N	\N	\N	\N
636	3	1	2025-04-10	\N	\N	\N	T250019446	Cylinder hydr.tłokowy	60221839.0	f	39/25	\N	\N	\N	\N	\N	\N	\N	\N
342	40	3	2025-04-10	\N	\N	\N	\N	\N	50043941	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
347	40	3	2025-04-09	\N	\N	\N	\N	\N	50043940	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
640	27	1	2025-04-09	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123804.0	f	41/25	\N	WZ	98806	2025-04-16	2493	00759007737284577507	Poczta Polska	6
38	3	2	2025-04-08	\N	\N	\N	T250001749	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
37	3	2	2025-04-08	\N	\N	\N	T250001689	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
637	79	1	2025-04-08	\N	\N	\N	RES/2024/11/2	Cylinder hydr tłokowy	60123801.0	f	40/25 / ZW	\N	\N	\N	\N	\N	\N	\N	\N
639	79	1	2025-04-08	\N	\N	\N	RES/2025/03/4	Cylinder hydr.tłokowy	60123803.0	f	40/25	\N	\N	\N	\N	\N	\N	\N	\N
638	79	1	2025-04-08	\N	\N	\N	RES/2025/03/2	Cylinder hydr.tłokowy	60123802.0	f	40/25	\N	\N	\N	\N	\N	\N	\N	\N
36	3	2	2025-04-08	\N	\N	\N	T250009606	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
631	3	1	2025-04-07	\N	\N	\N	T250006895	Cylinder hydr.tłokowy	60221834.0	f	39/25	\N	korekta	49/U/25	\N	\N	\N	\N	7
632	3	1	2025-04-07	\N	\N	\N	T250005026	Cylinder hydr.tłokowy	60221835.0	f	39/25	\N	korekta	49/U/25	\N	\N	\N	\N	7
633	3	1	2025-04-07	\N	\N	\N	T250002996	Cylinder hydr.tłokowy	60221836.0	f	39/25	\N	ZW	20148	\N	\N	\N	\N	34
630	3	1	2025-04-07	\N	\N	\N	T250012903	Cylinder hydr.tłokowy	60221833.0	f	39/25	\N	korekta	48/U/25	\N	\N	\N	\N	7
635	3	1	2025-04-07	\N	\N	\N	T250009692	Cylinder hydr.tłokowy	60221838.0	f	39/25	\N	\N	\N	\N	\N	\N	\N	\N
634	3	1	2025-04-07	\N	\N	\N	T250001911	Cylinder hydr.tłokowy	60221837.0	f	39/25	\N	\N	\N	\N	\N	\N	\N	\N
427	9	3	2025-04-04	\N	\N	\N	\N	\N	50043813	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
272	31	3	2025-04-03	\N	\N	\N	\N	\N	50852233	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
205	37	3	2025-04-02	\N	\N	\N	\N	\N	50043842	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
293	33	3	2025-04-02	\N	\N	\N	\N	\N	50852280	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
625	33	1	2025-04-02	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221831.0	f	37/25  zw	\N	\N	\N	\N	\N	\N	\N	\N
629	63	1	2025-04-02	\N	\N	\N	\N	Cylinder hydr.nurnikowy	60221832.0	f	38/25	\N	WZ	98985	2025-05-08	2493	DL35326/GEODIS	Firma spedycyjna	27
623	69	1	2025-04-01	\N	\N	\N	L10075062	Cylinder hydr.teleskopowy	60221829.0	f	36/25	\N	WZ	98936	2025-04-30	2493	2728749926	Schenker	22
624	69	1	2025-04-01	\N	\N	\N	L10075223	Cylinder hydr.teleskopowy	60221830.0	f	36/25	\N	WZ	98936	2025-04-30	2493	2728749926	Schenker	22
622	27	1	2025-03-31	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123800.0	f	35/25	\N	WZ	98749	2025-04-08	2493	0000037321350T	DPD	7
616	66	1	2025-03-27	\N	\N	\N	200034389	Cylinder hydr.nurnikowy	60221823.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
608	66	1	2025-03-27	\N	\N	\N	200034428	Cylinder hydr.nurnikowy	60221815.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
618	66	1	2025-03-27	\N	\N	\N	200033964	Cylinder hydr.nurnikowy	60221825.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
617	66	1	2025-03-27	\N	\N	\N	200033965	Cylinder hydr.nurnikowy	60221824.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
609	66	1	2025-03-27	\N	\N	\N	200034427	Cylinder hydr.nurnikowy	60221816.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
612	66	1	2025-03-27	\N	\N	\N	200034422	Cylinder hydr.tłokowy	60221819.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
610	66	1	2025-03-27	\N	\N	\N	200034426	Cylinder hydr.nurnikowy	60221817.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
614	66	1	2025-03-27	\N	\N	\N	200034398	Cylinder hydr.tłokowy	60221821.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
619	66	1	2025-03-27	\N	\N	\N	200033963	Cylinder hydr.nurnikowy	60221826.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
611	66	1	2025-03-27	\N	\N	\N	200034425	Cylinder hydr.tłokowy	60221818.0	f	34/25  zw	\N	\N	\N	\N	\N	\N	\N	\N
620	66	1	2025-03-27	\N	\N	\N	200034458	Cylinder hydr.nurnikow	60221827.0	f	34/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
613	66	1	2025-03-27	\N	\N	\N	200034419	Cylinder hydr.nurnikowy	60221820.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
621	66	1	2025-03-27	\N	\N	\N	200034457	Cylinder hydr.nurnikowy	60221828.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
615	66	1	2025-03-27	\N	\N	\N	200034397	Cylinder hydr.tłokowy	60221822.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
607	66	1	2025-03-27	\N	\N	\N	200034429	Cylinder hydr.tłokowy	60221814.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
603	66	1	2025-03-26	\N	\N	\N	200034462	Cylinder hydr.tłokowy	60221812.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
602	66	1	2025-03-26	\N	\N	\N	200034463	Cylinder hydr.tłokowy	60221811.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
597	64	1	2025-03-26	\N	\N	\N	9/2025	Cylinder hydr.tłokowy	60123799.0	f	33/25	\N	WZ	98732	2025-03-31	2493	0000037239993T	DPD	4
604	66	1	2025-03-26	\N	\N	\N	200034461	Cylinder hydr.nurnikowy	60221813.0	f	34/25 zw 1 szt	\N	\N	\N	\N	\N	\N	\N	\N
177	9	3	2025-03-26	\N	\N	\N	\N	\N	50852190	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
601	66	1	2025-03-26	\N	\N	\N	200034464	Cylinder hydr.nurnikow	60221810.0	f	34/25 zw 	\N	\N	\N	\N	\N	\N	\N	\N
598	66	1	2025-03-26	\N	\N	\N	200034467	Cylinder hydr.tłokowy	60221807.0	f	34/25 zw 	\N	\N	\N	\N	\N	\N	\N	\N
600	66	1	2025-03-26	\N	\N	\N	200034465	Cylinder hydr.nurnikowy	60221809.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
599	66	1	2025-03-26	\N	\N	\N	200034466	Cylinder hydr.nurnikowy	60221808.0	f	34/25	\N	\N	\N	\N	\N	\N	\N	\N
339	45	3	2025-03-25	\N	\N	\N	\N	\N	50852109	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
392	48	3	2025-03-25	\N	\N	\N	\N	\N	50852384	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
228	45	3	2025-03-24	\N	\N	\N	\N	\N	50852106	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
596	14	1	2025-03-24	\N	\N	\N	KD 513659	Cylinder hydr.tłokowy	60221806.0	f	32/25/ zw 2494	\N	\N	\N	\N	\N	\N	\N	\N
595	82	1	2025-03-20	\N	\N	\N	\N	Cylinder hydr.teleskopowy	60123798.0	f	31/25	\N	WZ	98559	2025-03-21	2493	00759007737271269002	Poczta Polska	2
594	37	1	2025-03-20	\N	\N	\N	\N	Tłoczysko 35 R421E2 	60123797.0	f	30/25	\N	WZ	\N	\N	\N	\N	\N	\N
588	33	1	2025-03-19	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221804.0	f	28/25	\N	\N	\N	\N	\N	\N	\N	\N
581	12	1	2025-03-19	\N	\N	\N	2080372	Cylinder hydr.tłokowy	60221802.0	f	27/25	\N	WZ	98746	2025-04-08	2493	DASCHER DWR3125T	Firma spedycyjna	15
593	81	1	2025-03-19	\N	\N	\N	\N	Cylinder hydr.teleskopowy	60123796.0	f	29/25	\N	WZ	98560	2025-03-21	2493	0000037139310T	DPD	3
582	33	1	2025-03-19	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221803.0	f	28/25 zw	\N	\N	\N	\N	\N	\N	\N	\N
589	33	1	2025-03-19	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221805.0	f	28/25  zw	\N	\N	\N	\N	\N	\N	\N	\N
162	37	3	2025-03-14	\N	\N	\N	\N	\N	50043607	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
438	25	3	2025-03-14	\N	\N	\N	\N	\N	50043609	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
580	68	1	2025-03-13	\N	\N	\N	2960	Cylinder hydr.nurnikowy	60221801.0	f	26/25	\N	korekta	72/U/25	\N	\N	\N	\N	47
579	68	1	2025-03-13	\N	\N	\N	2956	Cylinder hydr.tłokowy	60221800.0	f	26/25	\N	WZ	98935	2025-04-30	2493	00659007737055466002	Poczta Polska	35
346	12	3	2025-03-13	\N	\N	\N	\N	\N	50043619	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
308	44	3	2025-03-12	\N	\N	\N	\N	\N	50043675	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
218	35	3	2025-03-12	\N	\N	\N	\N	\N	50043718	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	2	2	2025-03-12	\N	\N	\N	 21/25	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
381	33	3	2025-03-12	\N	\N	\N	\N	\N	50043711	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
288	27	3	2025-03-12	\N	\N	\N	\N	\N	50043699	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
324	3	3	2025-03-12	\N	\N	\N	\N	\N	50642067	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	2	2	2025-03-12	\N	\N	\N	 21/25	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
492	45	3	2025-03-11	\N	\N	\N	\N	\N	50043656	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
576	41	1	2025-03-10	\N	\N	\N	220002344	Cylinder hydr.tłokowy	60221798.0	f	23/25	\N	korekta	63/U/25	\N	\N	\N	\N	43
578	29	1	2025-03-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123795.0	f	23/25	\N	korekta	39/K/25	\N	\N	\N	\N	28
577	41	1	2025-03-10	\N	\N	\N	220002424	Cylinder hydr.tłokowy	60221799.0	f	24/25	\N	korekta	32/U/25	\N	\N	\N	\N	9
111	5	2	2025-03-06	\N	\N	\N	06032025	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
110	5	2	2025-03-06	\N	\N	\N	06032025	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
113	5	2	2025-03-06	\N	\N	\N	06032025	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
510	47	3	2025-03-06	\N	\N	\N	\N	\N	50043568	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
112	5	2	2025-03-06	\N	\N	\N	06032025	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
575	27	1	2025-03-05	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123794.0	f	22/25	\N	WZ	98455	2025-03-12	2493	00759007737265490009	Poczta Polska	6
160	10	3	2025-03-05	\N	\N	\N	\N	\N	50043400	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
43	3	2	2025-03-03	\N	\N	\N	T250001473	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	3	2	2025-03-03	\N	\N	\N	T250006895	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
42	3	2	2025-03-03	\N	\N	\N	T250001335	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
44	3	2	2025-03-03	\N	\N	\N	T250006282	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
46	3	2	2025-03-03	\N	\N	\N	T250002012	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	3	2	2025-03-03	\N	\N	\N	T250001911	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
45	3	2	2025-03-03	\N	\N	\N	T250003987	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
41	3	2	2025-03-03	\N	\N	\N	T250002996	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	1	2	2025-03-03	\N	\N	\N	2200030710 	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
47	3	2	2025-03-03	\N	\N	\N	T250001315	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
239	21	3	2025-02-28	\N	\N	\N	\N	\N	50852127	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
573	20	1	2025-02-28	\N	\N	\N	\N	Cylinder hydr.nurnikowy	60221797.0	f	21/25 zw 2 szt 2494	\N	WZ	98471	2025-03-31	2493	B142ELC/CL24ELC	Odbiór własny	22
282	13	3	2025-02-25	\N	\N	\N	\N	\N	50852030	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
463	45	3	2025-02-25	\N	\N	\N	\N	\N	50043670	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
416	35	3	2025-02-25	\N	\N	\N	\N	\N	50043693	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
370	25	3	2025-02-25	\N	\N	\N	\N	\N	50052001	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
23	1	2	2025-01-17	\N	\N	\N	2200030381	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
517	40	3	2025-02-25	\N	\N	\N	\N	\N	50642130	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
443	3	3	2025-02-25	\N	\N	\N	\N	\N	50942502	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
572	5	1	2025-02-25	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221796.0	f	20/25	\N	WZ	98543	2025-03-27	2493	M.FILIPIAK	Transport Agromet	23
229	31	3	2025-02-21	\N	\N	\N	\N	\N	50852011	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
195	28	3	2025-02-21	\N	\N	\N	\N	\N	50642059	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
357	25	3	2025-02-21	\N	\N	\N	\N	\N	50642040	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
267	6	3	2025-02-20	\N	\N	\N	\N	\N	50642024	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
200	35	3	2025-02-20	\N	\N	\N	\N	\N	50043513	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
115	6	2	2025-02-20	\N	\N	\N	20250220	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
373	24	3	2025-02-20	\N	\N	\N	\N	\N	50851620	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
570	76	1	2025-02-20	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123793.0	f	19/25	\N	WZ	98462	2025-03-14	2493	00759007737267961002	Poczta Polska	17
354	3	3	2025-02-20	\N	\N	\N	\N	\N	50942338	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
116	6	2	2025-02-20	\N	\N	\N	20250220	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
114	6	2	2025-02-20	\N	\N	\N	20250220	Cylinder nurnikowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
569	76	1	2025-02-20	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123792.0	f	19/25	\N	WZ	98462	2025-03-14	2493	00759007737267961002	Poczta Polska	17
567	41	1	2025-02-19	\N	\N	\N	220002344	Cylinder hydr.tłokowy	60221794.0	f	17/25	\N	korekta	xxx	\N	\N	\N	\N	56
568	42	1	2025-02-19	\N	\N	\N	113088	Cylinder hydr.tłokowy	60221795.0	f	18/25	\N	WZ	98476	2025-03-14	2493	00659007737053782005	Poczta Polska	18
566	41	1	2025-02-18	\N	\N	\N	220002316	Cylinder hydr.tłokowy	60221793.0	f	16/25	\N	korekta	28/U/25	\N	\N	\N	\N	8
321	45	3	2025-02-17	\N	\N	\N	\N	\N	50043510	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
565	1	1	2025-02-17	\N	\N	\N	2200030712	Cylinder hydr.tłokowy	60123791.0	f	15/25	\N	korekta	13/K/25	\N	\N	\N	\N	-2
304	21	3	2025-02-14	\N	\N	\N	\N	\N	50641777	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
563	15	1	2025-02-13	\N	\N	\N	14048	Cylinder hydr.tłokowy	60123789.0	f	14/25	\N	WZ	98233	2025-02-25	2493	00759007737259790009	Poczta Polska	9
561	61	1	2025-02-13	\N	\N	\N	\N	Cylinder hydr.nurnikowy	60123788.0	f	13/25	\N	WZ	98448	2025-03-10	2493	00759007737264773004	Poczta Polska	18
564	15	1	2025-02-13	\N	\N	\N	14241	Cylinder hydr.tłokowy	60123790.0	f	14/25 zw	\N	WZ	98452	2025-03-11	2494	00759007737265483506	Poczta Polska	19
154	25	3	2025-02-12	\N	\N	\N	\N	\N	50842472	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
540	3	1	2025-02-11	\N	\N	\N	T250001315	Cylinder hydr.tłokowy	60221784.0	f	10/25	\N	korekta	16/U/25	\N	\N	\N	\N	-2
424	41	3	2024-11-22	\N	\N	\N	\N	\N	50043228	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
301	29	3	2025-02-11	\N	\N	\N	\N	\N	50043539	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
536	3	1	2025-02-11	\N	\N	\N	T250001689	Cylinder hydr.tłokowy	60221780.0	f	10/25 / zw	\N	korekta	19/U/25	\N	\N	\N	\N	3
537	3	1	2025-02-11	\N	\N	\N	T250001749	Cylinder hydr.tłokowy	60221781.0	f	10/25/ zw 	\N	korekta	23/U/25	\N	\N	\N	\N	5
538	3	1	2025-02-11	\N	\N	\N	T250002012	Cylinder hydr.tłokowy	60221782.0	f	10/25	\N	korekta	17/U/25	\N	\N	\N	\N	3
542	3	1	2025-02-11	\N	\N	\N	T250003987	Cylinder hydr.tłokowy	60221786.0	f	10/25	\N	korekta	24/U/25	\N	\N	\N	\N	6
541	3	1	2025-02-11	\N	\N	\N	T240070990	Cylinder hydr.tłokowy	60221785.0	f	10/25	\N	korekta	20/U/25	\N	\N	\N	\N	3
545	40	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221788.0	f	11/25 zw 2 szt	\N	WZ	98463	2025-03-13	2493	\N	Odbiór własny	23
548	40	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221789.0	f	11/25 zw 2 szt	\N	ZW złom	19886	\N	\N	\N	\N	22
554	40	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221791.0	f	11/25 zw 3 szt	\N	WZ	98463	2025-03-13	2493	\N	Odbiór własny	23
539	3	1	2025-02-11	\N	\N	\N	T240069504	Cylinder hydr.tłokowy	60221783.0	f	10/25	\N	korekta	16/U/25	\N	\N	\N	\N	3
552	40	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221790.0	f	11/25 zw 9 szt	\N	WZ	98463	2025-03-13	2493	\N	Odbiór własny	23
556	33	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221792.0	f	12/25 - 3 szt zw 2494	\N	\N	\N	\N	\N	\N	\N	\N
543	40	1	2025-02-11	\N	\N	\N	\N	Cylinder hydr.tłokowy	60221787.0	f	11/25 zw 6 szt	\N	WZ	98463	2025-03-13	2493	\N	Odbiór własny	23
296	44	3	2025-02-10	\N	\N	\N	\N	\N	50043377	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
507	21	3	2025-02-10	\N	\N	\N	\N	\N	50851888	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
169	33	3	2025-02-07	\N	\N	\N	\N	\N	50851931	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
330	38	3	2025-02-07	\N	\N	\N	\N	\N	50043424	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
402	35	3	2025-02-07	\N	\N	\N	\N	\N	50641950	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	1	2	2025-02-06	\N	\N	\N	2200030581	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	1	2	2025-02-06	\N	\N	\N	2200030712	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
458	35	3	2025-02-06	\N	\N	\N	\N	\N	50043608	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
532	6	1	2025-02-06	\N	\N	\N	2025-00295	Cylinder hydr.nurnikowy	60123784.0	f	8/25	\N	WZ	98228	2025-02-24	2493	M.FILIPIAK	Transport Agromet	13
535	1	1	2025-02-06	\N	\N	\N	2200030693	Cylinder hydr tłokowy	60123787.0	f	9/25	\N	korekta	6/K/25	\N	\N	\N	\N	1
533	6	1	2025-02-06	\N	\N	\N	2025-00295	Cylinder hydr.nurnikowy	60123785.0	f	8/25	\N	WZ	98228	2025-02-24	2493	M.FILIPIAK	Transport Agromet	13
226	1	3	2025-02-06	\N	\N	\N	\N	\N	50043565	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
534	6	1	2025-02-06	\N	\N	\N	2025-00295	Cylinder hydr.nurnikowy	60123786.0	f	8/25	\N	WZ	98185	2025-02-18	2493	M,FILIPIAK	Transport Agromet	9
401	45	3	2025-02-04	\N	\N	\N	\N	\N	50043486	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
531	77	1	2025-02-04	\N	\N	\N	\N	Cylinder hydr.nurnikowy	60221779.0	f	7/25	\N	WZ	98730	2025-03-31	2493	WS 8457G	Firma spedycyjna	40
530	41	1	2025-01-30	\N	\N	\N	220002241	Cylinder hydr.tłokowy	60221778.0	f	6/25	\N	korekta	33/U/25	\N	\N	\N	\N	36
343	39	3	2025-01-29	\N	\N	\N	\N	\N	50043479	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
294	42	3	2025-01-29	\N	\N	\N	\N	\N	50043415	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
305	9	3	2025-01-28	\N	\N	\N	\N	\N	50115818	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
168	40	3	2025-01-28	\N	\N	\N	\N	\N	50043455	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
220	29	3	2025-02-05	\N	\N	\N	\N	\N	50043653	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
292	29	3	2025-02-03	\N	\N	\N	\N	\N	50642008	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
432	29	3	2025-01-28	\N	\N	\N	\N	\N	50641932	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
344	29	3	2025-01-28	\N	\N	\N	\N	\N	50043541	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
146	29	3	2025-01-23	\N	\N	\N	\N	\N	50641906	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
413	45	3	2025-01-27	\N	\N	\N	\N	\N	50641921	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
529	1	1	2025-01-27	\N	\N	\N	2200030535	Cylinder hydr.tłokowy	60123783.0	f	5/25	\N	korekta	5/K/24	\N	\N	\N	\N	1
528	1	1	2025-01-27	\N	\N	\N	2200030577	Cylinder hydr.tłokowy	60123782.0	f	5/25	\N	korekta	4/K/24	\N	\N	\N	\N	1
201	35	3	2025-01-24	\N	\N	\N	\N	\N	50043546	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
494	1	3	2025-01-24	\N	\N	\N	\N	\N	50641854	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
496	9	3	2025-01-24	\N	\N	\N	\N	\N	50043495	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
361	30	3	2025-01-24	\N	\N	\N	\N	\N	50043452	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
502	31	3	2025-01-24	\N	\N	\N	\N	\N	50043422	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
429	21	3	2025-01-23	\N	\N	\N	\N	\N	50851716	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
277	5	3	2025-01-23	\N	\N	\N	\N	\N	50942298	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
430	1	3	2025-01-22	\N	\N	\N	\N	\N	50043437	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
526	62	1	2025-01-22	\N	\N	\N	LR24001463	Cylinder hydr.tłokowy	60123780.0	f	3/25 / orekta do zamknięcia	\N	korekta	2/K/25	\N	\N	\N	\N	1
459	33	3	2025-01-22	\N	\N	\N	\N	\N	50851550	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
527	1	1	2025-01-22	\N	\N	\N	2200030581	Cylinder hydr.tłokowy	60123781.0	f	4/25 / korekta zlecenie do zamknięcia	\N	korekta	3/K/25	\N	\N	\N	\N	1
199	13	3	2025-01-22	\N	\N	\N	\N	\N	51906628	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
376	30	3	2025-01-21	\N	\N	\N	\N	\N	50641833	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
253	45	3	2025-01-21	\N	\N	\N	\N	\N	50641662	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
495	39	3	2025-01-21	\N	\N	\N	\N	\N	50641882	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
486	45	3	2025-01-20	\N	\N	\N	\N	\N	50043293	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
525	1	1	2025-01-20	\N	\N	\N	2200030564	Cylinder hydr.tłokowy	60123779.0	f	2/25 / korekta do zamknięcia	\N	korekta	1/K/25	\N	 	\N	\N	2
206	1	3	2025-01-18	\N	\N	\N	\N	\N	50423268	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
461	1	3	2025-01-18	\N	\N	\N	\N	\N	50423269	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	1	2	2025-01-17	\N	\N	\N	2200030535	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
203	5	3	2025-01-17	\N	\N	\N	\N	\N	50851813	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
414	45	3	2025-01-17	\N	\N	\N	\N	\N	50641770	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
25	1	2	2025-01-17	\N	\N	\N	2200030381	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
24	1	2	2025-01-17	\N	\N	\N	2200030381	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	1	2	2025-01-17	\N	\N	\N	2200030445	Zawór zwrotny	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	1	2	2025-01-17	\N	\N	\N	2200030445	Zawór zwrotny	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	1	2	2025-01-17	\N	\N	\N	2200030564	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	1	2	2025-01-17	\N	\N	\N	2200030337	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	1	2	2025-01-17	\N	\N	\N	2200030337	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
20	1	2	2025-01-17	\N	\N	\N	2200030337	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
19	1	2	2025-01-17	\N	\N	\N	2200030398	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	1	2	2025-01-17	\N	\N	\N	2200030398	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	1	2	2025-01-17	\N	\N	\N	2200030398	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	1	2	2025-01-17	\N	\N	\N	2200030535	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	1	2	2025-01-17	\N	\N	\N	2200030535	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
230	5	3	2025-01-16	\N	\N	\N	\N	\N	50641880	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
213	23	3	2025-01-16	\N	\N	\N	\N	\N	50043403	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
202	41	3	2025-01-16	\N	\N	\N	\N	\N	50641801	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
261	45	3	2025-01-15	\N	\N	\N	\N	\N	51906580	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
186	29	3	2025-01-15	\N	\N	\N	\N	\N	50641934	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
53	4	2	2025-01-14	\N	\N	\N	4500183989-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
469	29	3	2024-12-19	\N	\N	\N	\N	\N	500443353	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
54	4	2	2025-01-14	\N	\N	\N	4500183989-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
52	4	2	2025-01-14	\N	\N	\N	4500183989-04	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
524	27	1	2025-01-14	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123778.0	f	1/25	\N	WZ	97933	2025-01-22	2493	0000036559284T	DPD	7
523	27	1	2025-01-14	\N	\N	\N	\N	Cylinder hydr.tłokowy	60123777.0	f	1/25 zw 2494	\N	WZ	97934	2025-01-22	2494	0000036559284T	DPD	7
59	4	2	2025-01-13	\N	\N	\N	4500183989-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
61	4	2	2025-01-13	\N	\N	\N	4500183989-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
62	4	2	2025-01-13	\N	\N	\N	4500183989-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
63	4	2	2025-01-13	\N	\N	\N	4500183989-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
64	4	2	2025-01-13	\N	\N	\N	4500183989-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
65	4	2	2025-01-13	\N	\N	\N	4500183989-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
55	4	2	2025-01-13	\N	\N	\N	4500182736-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
56	4	2	2025-01-13	\N	\N	\N	4500182736-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
57	4	2	2025-01-13	\N	\N	\N	4500182736-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
58	4	2	2025-01-13	\N	\N	\N	4500182736-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
60	4	2	2025-01-13	\N	\N	\N	4500183989-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
403	41	3	2025-01-10	\N	\N	\N	\N	\N	50641806	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
67	4	2	2025-01-09	\N	\N	\N	4500184117	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
425	33	3	2025-01-09	\N	\N	\N	\N	\N	50641689	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
66	4	2	2025-01-09	\N	\N	\N	4500184107	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
219	19	3	2025-01-08	\N	\N	\N	\N	\N	50641803	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
335	45	3	2025-01-08	\N	\N	\N	\N	\N	50043194	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
74	4	2	2025-01-08	\N	\N	\N	4500183989	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
289	40	3	2025-01-08	\N	\N	\N	\N	\N	50043453	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
68	4	2	2025-01-08	\N	\N	\N	4500184107	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
69	4	2	2025-01-08	\N	\N	\N	4500184107	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
316	33	3	2025-01-08	\N	\N	\N	\N	\N	50851549	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
179	45	3	2025-01-08	\N	\N	\N	\N	\N	50043291	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
75	4	2	2025-01-07	\N	\N	\N	4500182827-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
70	4	2	2025-01-07	\N	\N	\N	4500182827-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
71	4	2	2025-01-07	\N	\N	\N	4500182827-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
72	4	2	2025-01-07	\N	\N	\N	4500182827-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
73	4	2	2025-01-07	\N	\N	\N	4500182827-03	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
76	4	2	2025-01-07	\N	\N	\N	4500182827-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
77	4	2	2025-01-07	\N	\N	\N	4500182827-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
78	4	2	2025-01-07	\N	\N	\N	4500182827-02	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
79	4	2	2025-01-07	\N	\N	\N	4500182763-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
80	4	2	2025-01-07	\N	\N	\N	4500182763	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	1	2	2025-01-03	\N	\N	\N	2200030326	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	1	2	2025-01-03	\N	\N	\N	2200030326	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
49	3	2	2025-01-03	\N	\N	\N	T240069504	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
50	3	2	2025-01-03	\N	\N	\N	T240069924	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
51	3	2	2025-01-03	\N	\N	\N	T240070990	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
48	3	2	2025-01-03	\N	\N	\N	T240070990	Cylinder tłokowy	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
183	3	3	2024-12-20	\N	\N	\N	\N	\N	50043280	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
488	45	3	2024-12-19	\N	\N	\N	\N	\N	Reklamacja	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
500	15	3	2024-12-17	\N	\N	\N	\N	\N	50851684	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
210	37	3	2024-12-12	\N	\N	\N	\N	\N	50043167	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
320	3	3	2024-12-12	\N	\N	\N	\N	\N	50641758	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
222	21	3	2024-12-12	\N	\N	\N	\N	\N	50851558	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
88	4	2	2024-12-10	\N	\N	\N	4500182736-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
87	4	2	2024-12-10	\N	\N	\N	4500182736-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
86	4	2	2024-12-10	\N	\N	\N	4500182736-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
85	4	2	2024-12-10	\N	\N	\N	4500182736-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
84	4	2	2024-12-10	\N	\N	\N	4500182827-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
83	4	2	2024-12-10	\N	\N	\N	4500182827-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
82	4	2	2024-12-10	\N	\N	\N	4500182827-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
81	4	2	2024-12-10	\N	\N	\N	4500182827-01	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
279	20	3	2024-12-09	\N	\N	\N	\N	\N	50042673	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
441	1	3	2024-12-09	\N	\N	\N	\N	\N	50641850	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
187	33	3	2024-12-05	\N	\N	\N	\N	\N	50641633	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
363	38	3	2024-12-05	\N	\N	\N	\N	\N	50043260	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
466	39	3	2024-12-05	\N	\N	\N	\N	\N	50851765	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
96	4	2	2024-12-04	\N	\N	\N	4500182827	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
95	4	2	2024-12-04	\N	\N	\N	4500182827	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
94	4	2	2024-12-04	\N	\N	\N	4500182827	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
93	4	2	2024-12-04	\N	\N	\N	4500182827	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
98	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
99	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
100	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
101	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
102	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
103	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
92	4	2	2024-12-04	\N	\N	\N	4500182717	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
91	4	2	2024-12-04	\N	\N	\N	4500182717	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
90	4	2	2024-12-04	\N	\N	\N	4500182717	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
89	4	2	2024-12-04	\N	\N	\N	4500182717	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
355	40	3	2024-12-04	\N	\N	\N	\N	\N	50942208	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
107	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
97	4	2	2024-12-04	\N	\N	\N	4500182813	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
104	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
106	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
109	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
108	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
105	4	2	2024-12-04	\N	\N	\N	4500182736	Cylinder	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
407	13	3	2024-12-02	\N	\N	\N	\N	\N	50851438	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
365	12	3	2024-12-02	\N	\N	\N	\N	\N	50641717	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
275	18	3	2024-11-28	\N	\N	\N	\N	\N	50043133	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
196	27	3	2024-11-27	\N	\N	\N	\N	\N	50043327	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
499	13	3	2024-11-27	\N	\N	\N	\N	\N	50641663	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
454	37	3	2024-11-27	\N	\N	\N	\N	\N	50043357	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
352	3	3	2024-11-26	\N	\N	\N	\N	\N	50851453	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
317	6	3	2024-11-26	\N	\N	\N	\N	\N	50641712	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
297	24	3	2024-11-23	\N	\N	\N	\N	\N	50043346	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
270	45	3	2024-11-22	\N	\N	\N	\N	\N	50042815	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
379	1	3	2024-11-21	\N	\N	\N	\N	\N	50043007	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
477	45	3	2024-11-20	\N	\N	\N	\N	\N	50641433	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
472	33	3	2024-11-20	\N	\N	\N	\N	\N	50043095	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
265	1	3	2024-11-20	\N	\N	\N	\N	\N	50641668	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
386	9	3	2024-11-19	\N	\N	\N	\N	\N	50641773	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
181	30	3	2024-11-19	\N	\N	\N	\N	\N	50043093	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
340	35	3	2024-11-18	\N	\N	\N	\N	\N	50641669	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
171	45	3	2024-11-18	\N	\N	\N	\N	\N	50641276	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
444	1	3	2024-11-15	\N	\N	\N	\N	\N	50641688	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
236	24	3	2024-11-15	\N	\N	\N	\N	\N	50851511	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
436	41	3	2024-11-14	\N	\N	\N	\N	\N	50641611	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
248	45	3	2024-11-13	\N	\N	\N	\N	\N	50641614	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
192	1	3	2024-11-12	\N	\N	\N	\N	\N	50043316	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
250	3	3	2024-11-05	\N	\N	\N	\N	\N	50641522	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
319	11	3	2024-10-31	\N	\N	\N	\N	\N	50850892	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
391	37	3	2024-10-31	\N	\N	\N	\N	\N	50043168	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
159	31	3	2024-10-30	\N	\N	\N	\N	\N	50641608	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
490	7	3	2024-10-30	\N	\N	\N	\N	\N	50851214	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
223	15	3	2024-10-28	\N	\N	\N	\N	\N	50641596	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
216	41	3	2024-10-28	\N	\N	\N	\N	\N	50641558	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
152	47	3	2024-10-24	\N	\N	\N	\N	\N	50043121	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
224	37	3	2024-10-24	\N	\N	\N	\N	\N	50043186	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
246	41	3	2024-10-23	\N	\N	\N	\N	\N	50043022	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
484	44	3	2024-10-18	\N	\N	\N	\N	\N	50641355	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
158	41	3	2024-10-18	\N	\N	\N	\N	\N	50941723	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
353	32	3	2024-10-17	\N	\N	\N	\N	\N	50042519	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
266	35	3	2024-10-17	\N	\N	\N	\N	\N	50043147	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
174	5	3	2024-10-16	\N	\N	\N	\N	\N	50043179	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
252	3	3	2024-10-15	\N	\N	\N	\N	\N	50851323	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
191	30	3	2024-10-11	\N	\N	\N	\N	\N	50043153	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
334	45	3	2024-10-10	\N	\N	\N	\N	\N	50641430	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
364	45	3	2024-10-10	\N	\N	\N	\N	\N	50043015	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
333	15	3	2024-10-09	\N	\N	\N	\N	\N	50042458	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
442	32	3	2024-10-09	\N	\N	\N	\N	\N	50042759	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
451	3	3	2024-10-04	\N	\N	\N	\N	\N	50851194	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
150	45	3	2024-10-03	\N	\N	\N	\N	\N	50641494	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
211	45	3	2024-10-03	\N	\N	\N	\N	\N	50642430	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
481	41	3	2024-10-01	\N	\N	\N	\N	\N	50941746	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
415	30	3	2024-10-01	\N	\N	\N	\N	\N	50641549	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
302	9	3	2024-09-30	\N	\N	\N	\N	\N	50641541	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
359	3	3	2024-09-30	\N	\N	\N	\N	\N	50115809	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
431	5	3	2024-09-26	\N	\N	\N	\N	\N	50043162	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
410	45	3	2024-09-25	\N	\N	\N	\N	\N	50851101	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
212	45	3	2024-09-25	\N	\N	\N	\N	\N	50042992	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
467	30	3	2024-09-25	\N	\N	\N	\N	\N	50043091	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
269	45	3	2024-09-25	\N	\N	\N	\N	\N	50641267	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
311	33	3	2024-09-24	\N	\N	\N	\N	\N	50043266	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
300	33	3	2024-09-24	\N	\N	\N	\N	\N	50042878	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
400	41	3	2024-09-23	\N	\N	\N	\N	\N	50851137	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
448	5	3	2024-09-23	\N	\N	\N	\N	\N	50042886	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
341	13	3	2024-09-20	\N	\N	\N	\N	\N	50851096	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
180	32	3	2024-09-20	\N	\N	\N	\N	\N	50042758	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
460	45	3	2024-09-13	\N	\N	\N	\N	\N	50042865	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
178	33	3	2024-09-09	\N	\N	\N	\N	\N	50641361	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
508	35	3	2024-09-09	\N	\N	\N	\N	\N	50043054	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
476	12	3	2024-09-09	\N	\N	\N	\N	\N	50641544	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
409	12	3	2024-09-06	\N	\N	\N	\N	\N	50641242	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
395	33	3	2024-09-06	\N	\N	\N	\N	\N	50941844	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
498	30	3	2024-09-06	\N	\N	\N	\N	\N	50851126	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
285	33	3	2024-09-06	\N	\N	\N	\N	\N	50042879	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
242	12	3	2024-09-04	\N	\N	\N	\N	\N	50641243	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
338	30	3	2024-09-04	\N	\N	\N	\N	\N	50043058	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
420	45	3	2024-08-30	\N	\N	\N	\N	\N	50541122	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
475	3	3	2024-08-29	\N	\N	\N	\N	\N	50641385	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
306	32	3	2024-08-28	\N	\N	\N	\N	\N	50941778	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
249	32	3	2024-08-28	\N	\N	\N	\N	\N	50115799	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
396	40	3	2024-08-27	\N	\N	\N	\N	\N	50042968	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
345	33	3	2024-08-27	\N	\N	\N	\N	\N	50941740	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
512	33	3	2024-08-26	\N	\N	\N	\N	\N	50641209	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
387	45	3	2024-08-26	\N	\N	\N	\N	\N	50042563	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
456	45	3	2024-08-23	\N	\N	\N	\N	\N	50641224	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
256	45	3	2024-08-22	\N	\N	\N	\N	\N	50641319	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
157	45	3	2024-08-14	\N	\N	\N	\N	\N	50641216	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
247	3	3	2024-08-13	\N	\N	\N	\N	\N	50850772	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
241	40	3	2024-08-13	\N	\N	\N	\N	\N	50941538	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
332	45	3	2024-08-12	\N	\N	\N	\N	\N	50641269	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
197	1	3	2024-08-07	\N	\N	\N	\N	\N	50641222	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
404	45	3	2024-08-07	\N	\N	\N	\N	\N	50641171	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
465	30	3	2024-08-07	\N	\N	\N	\N	\N	50641297	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
421	30	3	2024-08-06	\N	\N	\N	\N	\N	50850952	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
336	30	3	2024-08-06	\N	\N	\N	\N	\N	50042949	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
480	35	3	2024-08-03	\N	\N	\N	\N	\N	50641332	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
453	45	3	2024-08-01	\N	\N	\N	\N	\N	50042796	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
397	35	3	2024-07-31	\N	\N	\N	\N	\N	50641336	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
327	41	3	2024-07-30	\N	\N	\N	\N	\N	50042955	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
209	45	3	2024-07-25	\N	\N	\N	\N	\N	50641286	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
273	3	3	2024-07-24	\N	\N	\N	\N	\N	50850978	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
286	25	3	2024-07-23	\N	\N	\N	\N	\N	50115801	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
349	45	3	2024-07-23	\N	\N	\N	\N	\N	50850898	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
185	43	3	2024-07-18	\N	\N	\N	\N	\N	50851074	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
489	33	3	2024-07-11	\N	\N	\N	\N	\N	50641147	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
184	26	3	2024-07-10	\N	\N	\N	\N	\N	50641134	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
501	32	3	2024-07-10	\N	\N	\N	\N	\N	50641021	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
423	30	3	2024-07-10	\N	\N	\N	\N	\N	50941279	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
474	13	3	2024-07-10	\N	\N	\N	\N	\N	50850778	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
399	13	3	2024-07-09	\N	\N	\N	\N	\N	50641175	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
457	44	3	2024-07-04	\N	\N	\N	\N	\N	50850675	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
485	45	3	2024-07-03	\N	\N	\N	\N	\N	50641104	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
198	43	3	2024-07-03	\N	\N	\N	\N	\N	50850577	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
516	41	3	2024-07-02	\N	\N	\N	\N	\N	50941386	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
238	3	3	2024-07-01	\N	\N	\N	\N	\N	50850645	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
225	1	3	2024-07-01	\N	\N	\N	\N	\N	50042817	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
449	12	3	2024-07-01	\N	\N	\N	\N	\N	50042736	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
518	26	3	2024-06-28	\N	\N	\N	\N	\N	50850733	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
445	32	3	2024-06-28	\N	\N	\N	\N	\N	50941259	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
511	1	3	2024-06-27	\N	\N	\N	\N	\N	50042171	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
298	33	3	2024-06-26	\N	\N	\N	\N	\N	50850816	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
166	22	3	2024-06-26	\N	\N	\N	\N	\N	50850416	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
148	3	3	2024-06-26	\N	\N	\N	\N	\N	50941369	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
278	29	3	2024-10-18	\N	\N	\N	\N	\N	50641583	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
290	29	3	2024-10-15	\N	\N	\N	\N	\N	50851301	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
358	29	3	2024-09-05	\N	\N	\N	\N	\N	50641468	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
383	29	3	2024-09-05	\N	\N	\N	\N	\N	50641467	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
164	49	3	2024-06-26	\N	\N	\N	\N	\N	50371988	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
513	15	3	2024-06-25	\N	\N	\N	\N	\N	50850797	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
245	22	3	2024-06-25	\N	\N	\N	\N	\N	60221673	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
382	36	3	2024-06-24	\N	\N	\N	\N	\N	50941361	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
405	45	3	2024-06-24	\N	\N	\N	\N	\N	50941254	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
380	30	3	2024-06-21	\N	\N	\N	\N	\N	50042838	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
280	20	3	2024-06-21	\N	\N	\N	\N	\N	50042271	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
309	30	3	2024-06-20	\N	\N	\N	\N	\N	50641118	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
231	45	3	2024-06-20	\N	\N	\N	\N	\N	50850653	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
470	30	3	2024-06-19	\N	\N	\N	\N	\N	50042778	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
313	3	3	2024-06-17	\N	\N	\N	\N	\N	50042701	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
263	45	3	2024-06-14	\N	\N	\N	\N	\N	50641041	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
314	20	3	2024-06-14	\N	\N	\N	\N	\N	50641016	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
232	45	3	2024-06-13	\N	\N	\N	\N	\N	50042602	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
446	33	3	2024-06-12	\N	\N	\N	\N	\N	50641020	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
412	1	3	2024-06-10	\N	\N	\N	\N	\N	50641055	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
233	40	3	2024-06-07	\N	\N	\N	\N	\N	50042730	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
264	33	3	2024-06-06	\N	\N	\N	\N	\N	50850597	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
193	33	3	2024-06-05	\N	\N	\N	\N	\N	50641048	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
262	40	3	2024-06-04	\N	\N	\N	\N	\N	50850615	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
369	43	3	2024-06-04	\N	\N	\N	\N	\N	50850579	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
452	47	3	2024-06-04	\N	\N	\N	\N	\N	50042545	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
207	45	3	2024-06-04	\N	\N	\N	\N	\N	50641014	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
362	47	3	2024-06-03	\N	\N	\N	\N	\N	50042727	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
257	45	3	2024-05-29	\N	\N	\N	\N	\N	50850720	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
276	45	3	2024-05-29	\N	\N	\N	\N	\N	50641126	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
204	16	3	2024-05-29	\N	\N	\N	\N	\N	50641011	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
325	3	3	2024-05-28	\N	\N	\N	\N	\N	50641165	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
435	3	3	2024-05-28	\N	\N	\N	\N	\N	50941165	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
234	3	3	2024-05-27	\N	\N	\N	\N	\N	50641037	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
312	45	3	2024-05-24	\N	\N	\N	\N	\N	50640946	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
144	39	3	2024-05-23	\N	\N	\N	\N	\N	50850621	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
260	45	3	2024-05-21	\N	\N	\N	\N	\N	50640947	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
163	19	3	2024-05-21	\N	\N	\N	\N	\N	50042505	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
299	14	3	2024-05-21	\N	\N	\N	\N	\N	50042686	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
151	45	3	2024-05-20	\N	\N	\N	\N	\N	50850469	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
514	31	3	2024-05-20	\N	\N	\N	\N	\N	50850664	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
491	1	3	2024-05-16	\N	\N	\N	\N	\N	50042713	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
487	1	3	2024-05-16	\N	\N	\N	\N	\N	51906414	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
367	45	3	2024-05-15	\N	\N	\N	\N	\N	50640963	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
418	45	3	2024-05-15	\N	\N	\N	\N	\N	50640964	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
468	41	3	2024-05-15	\N	\N	\N	\N	\N	50641017	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
482	13	3	2024-05-15	\N	\N	\N	\N	\N	50941118	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
406	13	3	2024-05-14	\N	\N	\N	\N	\N	50850406	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
337	33	3	2024-05-13	\N	\N	\N	\N	\N	50042551	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
422	32	3	2024-05-11	\N	\N	\N	\N	\N	50042648	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
440	45	3	2024-05-10	\N	\N	\N	\N	\N	50042361	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
411	45	3	2024-05-07	\N	\N	\N	\N	\N	50042501	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
161	3	3	2024-05-07	\N	\N	\N	\N	\N	50850414	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
214	3	3	2024-05-06	\N	\N	\N	\N	\N	50640912	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
393	19	3	2024-04-30	\N	\N	\N	\N	\N	50850516	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
156	19	3	2024-04-30	\N	\N	\N	\N	\N	50850515	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
227	33	3	2024-04-30	\N	\N	\N	\N	\N	50640956	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
271	45	3	2024-04-29	\N	\N	\N	\N	\N	50941140	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
287	42	3	2024-04-26	\N	\N	\N	\N	\N	50640839	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
172	43	3	2024-04-25	\N	\N	\N	\N	\N	50042578	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
398	22	3	2024-04-24	\N	\N	\N	\N	\N	50640940	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
315	16	3	2024-04-23	\N	\N	\N	\N	\N	50640887	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
165	3	3	2024-04-22	\N	\N	\N	\N	\N	50640896	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
258	1	3	2024-04-19	\N	\N	\N	\N	\N	50640999	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
244	32	3	2024-04-19	\N	\N	\N	\N	\N	50042571	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
408	33	3	2024-04-18	\N	\N	\N	\N	\N	50640959	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
374	3	3	2024-04-17	\N	\N	\N	\N	\N	50042528	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
281	45	3	2024-04-17	\N	\N	\N	\N	\N	50640883	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
372	16	3	2024-04-16	\N	\N	\N	\N	\N	50850368	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
283	9	3	2024-04-16	\N	\N	\N	\N	\N	50640981	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
351	32	3	2024-04-16	\N	\N	\N	\N	\N	50042568	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
433	41	3	2024-04-16	\N	\N	\N	\N	\N	50640893	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
385	44	3	2024-04-15	\N	\N	\N	\N	\N	50941057	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
190	1	3	2024-04-15	\N	\N	\N	\N	\N	50640889	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
145	41	3	2024-04-12	\N	\N	\N	\N	\N	50849999	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
417	3	3	2024-04-10	\N	\N	\N	\N	\N	50850286	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
348	41	3	2024-04-09	\N	\N	\N	\N	\N	50850313	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
450	3	3	2024-04-08	\N	\N	\N	\N	\N	50640973	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
251	41	3	2024-04-08	\N	\N	\N	\N	\N	50042301	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
464	42	3	2024-04-05	\N	\N	\N	\N	\N	50850287	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
188	33	3	2024-03-28	\N	\N	\N	\N	\N	50640744	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
426	3	3	2024-03-27	\N	\N	\N	\N	\N	50850302	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
217	3	3	2024-03-27	\N	\N	\N	\N	\N	50640847	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
389	35	3	2024-03-27	\N	\N	\N	\N	\N	50850349	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
360	3	3	2024-03-25	\N	\N	\N	\N	\N	50941040	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
509	5	3	2024-03-22	\N	\N	\N	\N	\N	50042479	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
208	32	3	2024-03-22	\N	\N	\N	\N	\N	50850358	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
274	32	3	2024-03-22	\N	\N	\N	\N	\N	50850354	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
153	33	3	2024-03-21	\N	\N	\N	\N	\N	50640742	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
506	41	3	2024-03-20	\N	\N	\N	\N	\N	50850307	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
331	34	3	2024-03-20	\N	\N	\N	\N	\N	50042399	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
437	45	3	2024-03-15	\N	\N	\N	\N	\N	60221617	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
515	45	3	2024-03-15	\N	\N	\N	\N	\N	50042500	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
268	45	3	2024-03-15	\N	\N	\N	\N	\N	50640768	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
303	43	3	2024-03-14	\N	\N	\N	\N	\N	50850193	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
254	45	3	2024-03-14	\N	\N	\N	\N	\N	51906356	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
322	45	3	2024-03-14	\N	\N	\N	\N	\N	51906357	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
215	11	3	2024-03-12	\N	\N	\N	\N	\N	50850196	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
497	33	3	2024-03-12	\N	\N	\N	\N	\N	50640783	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
375	31	3	2024-03-09	\N	\N	\N	\N	\N	50042496	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
323	3	3	2024-03-08	\N	\N	\N	\N	\N	50640851	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
388	33	3	2024-03-08	\N	\N	\N	\N	\N	50042493	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
394	45	3	2024-03-07	\N	\N	\N	\N	\N	51906355	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
377	22	3	2024-03-07	\N	\N	\N	\N	\N	50640799	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
284	5	3	2024-03-07	\N	\N	\N	\N	\N	50640928	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
434	30	3	2024-03-05	\N	\N	\N	\N	\N	50640790	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
428	37	3	2024-03-04	\N	\N	\N	\N	\N	50042427	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
189	45	3	2024-03-01	\N	\N	\N	\N	\N	50042329	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
368	37	3	2024-02-29	\N	\N	\N	\N	\N	50042429	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
170	33	3	2024-02-27	\N	\N	\N	\N	\N	50640681	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
173	22	3	2024-02-26	\N	\N	\N	\N	\N	50640708	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
328	13	3	2024-02-26	\N	\N	\N	\N	\N	50850269	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
149	22	3	2024-02-23	\N	\N	\N	\N	\N	50640706	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
366	41	3	2024-02-23	\N	\N	\N	\N	\N	50849898	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
237	37	3	2024-02-23	\N	\N	\N	\N	\N	50042446	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
471	30	3	2024-02-23	\N	\N	\N	\N	\N	50640760	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
235	13	3	2024-02-23	\N	\N	\N	\N	\N	50640880	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
307	29	3	2024-06-06	\N	\N	\N	\N	\N	50423241	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
504	29	3	2024-03-26	\N	\N	\N	\N	\N	50640900	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
291	29	3	2024-03-14	\N	\N	\N	\N	\N	50640765	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
147	30	3	2024-02-23	\N	\N	\N	\N	\N	50640699	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
419	33	3	2024-02-22	\N	\N	\N	\N	\N	50850062	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
194	30	3	2024-02-22	\N	\N	\N	\N	\N	50640698	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
240	41	3	2024-02-19	\N	\N	\N	\N	\N	50850000	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
356	40	3	2024-02-19	\N	\N	\N	\N	\N	50940652	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
384	3	3	2024-02-16	\N	\N	\N	\N	\N	50850177	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
478	37	3	2024-02-16	\N	\N	\N	\N	\N	50042425	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
318	1	3	2024-02-16	\N	\N	\N	\N	\N	50640611	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
519	41	3	2024-02-15	\N	\N	\N	\N	\N	50640572	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
350	17	3	2024-02-15	\N	\N	\N	\N	\N	50042449	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
455	33	3	2024-02-15	\N	\N	\N	\N	\N	50640782	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
329	5	3	2024-02-14	\N	\N	\N	\N	\N	50850211	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
176	45	3	2024-02-09	\N	\N	\N	\N	\N	60221608	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
255	41	3	2024-02-07	\N	\N	\N	\N	\N	50640643	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
479	33	3	2024-02-07	\N	\N	\N	\N	\N	50640679	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
182	8	3	2024-02-07	\N	\N	\N	\N	\N	50850259	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
462	27	3	2024-02-07	\N	\N	\N	\N	\N	50640693	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
483	31	3	2024-02-06	\N	\N	\N	\N	\N	50850156	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
378	33	3	2024-02-06	\N	\N	\N	\N	\N	50640784	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
167	17	3	2024-02-06	\N	\N	\N	\N	\N	50640607	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
503	37	3	2024-02-05	\N	\N	\N	\N	\N	50042415	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
243	3	3	2024-02-02	\N	\N	\N	\N	\N	50640589	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
175	5	3	2024-02-02	\N	\N	\N	\N	\N	50042389	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
371	1	3	2024-02-01	\N	\N	\N	\N	\N	50850105	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
493	32	3	2024-01-31	\N	\N	\N	\N	\N	50850026	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
221	1	3	2024-01-31	\N	\N	\N	\N	\N	50640659	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
310	45	3	2024-01-31	\N	\N	\N	\N	\N	50850009	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
447	43	3	2024-01-31	\N	\N	\N	\N	\N	50849968	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
259	33	3	2024-01-31	\N	\N	\N	\N	\N	50640552	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
326	11	3	2024-01-31	\N	\N	\N	\N	\N	50850003	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
155	1	3	2024-01-30	\N	\N	\N	\N	\N	50640661	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
439	33	3	2024-01-26	\N	\N	\N	\N	\N	50640549	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5034 (class 0 OID 19153)
-- Dependencies: 237
-- Data for Name: reklamacja_detal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reklamacja_detal (reklamacja_id, detal_id) FROM stdin;
3	18
4	18
5	18
6	11
7	11
8	8
9	40
10	18
11	21
12	21
20	3
21	3
22	3
23	24
24	24
25	24
26	24
27	24
28	31
29	31
30	33
31	12
32	37
33	37
34	35
35	9
36	26
37	14
38	14
39	33
40	19
41	35
42	5
43	41
44	7
46	33
47	19
48	16
49	9
50	37
51	16
52	38
53	25
54	25
55	23
56	23
57	23
58	23
59	17
60	17
61	17
62	28
63	28
64	28
65	28
66	22
67	10
68	22
69	22
70	23
71	23
72	23
73	23
74	38
75	17
75	29
75	34
75	39
76	17
76	29
76	34
76	39
77	17
77	29
77	34
77	39
78	17
78	29
78	34
78	39
79	23
80	27
81	4
81	10
81	34
82	4
82	10
82	34
83	4
83	10
83	34
84	4
84	10
84	34
85	38
86	38
87	38
88	38
89	28
90	28
91	28
92	28
93	28
94	28
95	28
96	28
97	23
97	25
97	28
97	30
97	34
97	38
97	42
98	23
98	25
98	28
98	30
98	34
98	38
98	42
99	23
99	25
99	28
99	30
99	34
99	38
99	42
100	23
100	25
100	28
100	30
100	34
100	38
100	42
101	23
101	25
101	28
101	30
101	34
101	38
101	42
102	23
102	25
102	28
102	30
102	34
102	38
102	42
103	23
103	25
103	28
103	30
103	34
103	38
103	42
104	6
104	17
104	22
104	25
104	28
104	34
105	6
105	17
105	22
105	25
105	28
105	34
106	6
106	17
106	22
106	25
106	28
106	34
107	6
107	17
107	22
107	25
107	28
107	34
108	6
108	17
108	22
108	25
108	28
108	34
109	6
109	17
109	22
109	25
109	28
109	34
110	20
111	20
112	20
113	20
114	13
114	15
114	32
115	13
115	15
115	32
116	13
116	15
116	32
231	156
509	236
468	166
162	228
476	92
243	129
158	233
425	154
501	188
163	240
319	157
409	92
434	67
189	54
303	225
266	263
145	214
309	136
195	200
276	195
276	130
502	260
149	104
184	163
514	210
369	224
310	190
507	164
268	53
332	54
332	199
180	151
206	3
384	202
345	116
377	103
454	278
290	102
450	142
510	122
198	179
221	59
222	164
318	94
463	13
385	58
399	139
420	87
430	269
167	100
192	266
512	74
282	62
439	74
334	54
338	254
475	129
156	206
284	80
379	249
348	180
480	95
455	197
215	160
194	134
214	129
168	253
387	237
456	54
491	64
417	69
264	184
432	140
471	135
474	62
394	119
414	131
245	219
413	130
155	68
322	205
508	277
378	74
171	86
265	159
263	54
355	63
159	83
456	196
320	165
452	122
176	241
446	118
459	185
478	231
232	28
207	152
305	280
372	158
333	151
429	164
401	34
511	18
227	113
356	112
291	187
183	9
321	23
178	75
499	139
279	31
337	145
392	220
500	215
448	80
259	75
449	267
431	212
368	228
161	170
398	56
419	184
182	213
346	267
267	84
207	86
327	273
436	166
483	210
273	69
495	144
503	232
489	113
396	248
457	172
302	146
271	123
144	108
229	234
380	262
313	183
244	270
388	276
242	71
405	124
179	23
247	101
411	55
382	203
336	136
439	154
352	101
412	65
240	193
242	282
200	281
393	173
451	217
270	38
375	85
238	101
172	111
440	38
253	174
278	186
181	259
461	261
428	229
418	174
306	208
408	177
427	283
204	98
295	73
486	4
498	235
166	219
147	66
515	23
467	265
386	143
312	86
383	96
493	182
237	230
362	121
426	222
175	80
325	77
504	141
435	168
235	139
469	243
223	138
391	232
424	273
287	149
256	57
485	86
497	78
389	221
170	75
366	214
433	107
203	191
506	201
280	250
364	10
272	155
230	110
464	117
157	120
212	23
406	62
275	239
443	167
422	264
349	285
453	34
470	265
151	171
466	88
513	215
225	18
299	109
293	184
339	285
360	207
246	274
367	223
210	231
255	114
283	93
188	147
447	60
274	181
261	125
307	252
258	99
193	145
197	176
250	76
174	242
257	218
441	91
407	62
198	161
216	166
311	145
228	156
374	37
190	176
233	257
209	162
248	128
403	166
404	54
217	82
341	62
488	28
371	192
146	97
479	177
329	211
437	241
314	133
254	204
251	268
185	161
281	194
477	162
353	189
519	166
494	169
187	154
460	34
388	150
484	127
331	198
211	54
326	61
376	137
251	284
350	178
285	271
262	153
487	52
160	272
234	81
153	106
173	105
323	79
208	182
289	257
252	101
448	279
505	23
472	276
351	245
300	184
260	175
358	72
324	76
328	227
465	70
482	115
165	148
315	89
277	209
365	71
340	132
610	30
618	34
528	3
621	34
572	20
609	25
588	271
612	22
634	33
629	240
600	28
539	9
633	35
541	16
567	273
602	23
635	35
636	12
616	34
613	25
604	34
565	8
542	16
552	248
570	254
537	14
611	23
631	19
607	23
594	229
543	257
632	9
536	14
576	273
603	27
599	6
615	17
548	253
530	273
630	37
532	15
527	18
529	3
620	38
649	239
581	267
573	31
614	17
577	273
598	17
525	3
534	32
540	19
601	38
617	28
533	13
619	34
608	30
538	33
651	269
\.


--
-- TOC entry 5036 (class 0 OID 19157)
-- Dependencies: 239
-- Data for Name: slownik_dzial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slownik_dzial (id, nazwa) FROM stdin;
1	PRODUKCJA
2	TECHNOLOGIA
3	ZAOPATRZENIE
4	ZARZĄDZANIE
5	MARKETING
6	KONTROLA_JAKOSCI
7	UTRZYMANIE_RUCHU
8	ZARZAD
\.


--
-- TOC entry 5038 (class 0 OID 19161)
-- Dependencies: 241
-- Data for Name: slownik_dzialanie_typ; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slownik_dzialanie_typ (id, nazwa) FROM stdin;
1	Działanie korygujące
2	Działanie korekcyjne
\.


--
-- TOC entry 5040 (class 0 OID 19165)
-- Dependencies: 243
-- Data for Name: slownik_sprawdzanie_typ; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slownik_sprawdzanie_typ (id, kod, nazwa) FROM stdin;
1	ZATW	Zatwierdzenie działań
2	SKUT	Skuteczność działań
\.


--
-- TOC entry 5042 (class 0 OID 19169)
-- Dependencies: 245
-- Data for Name: slownik_typ_audytu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slownik_typ_audytu (id, nazwa) FROM stdin;
2	zewnetrzny
1	wewnetrzny
\.


--
-- TOC entry 5044 (class 0 OID 19173)
-- Dependencies: 247
-- Data for Name: slownik_typ_reklamacji; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slownik_typ_reklamacji (id, nazwa) FROM stdin;
1	reklamacja
2	raport_8D
3	doskonalenie
\.


--
-- TOC entry 5046 (class 0 OID 19177)
-- Dependencies: 249
-- Data for Name: sprawdzanie_dzialan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sprawdzanie_dzialan (id, typ_id, data, uwagi, status) FROM stdin;
2	1	2024-05-19	\N	f
3	1	2024-09-15	\N	f
4	1	2024-07-30	\N	f
5	1	2024-10-10	\N	f
6	1	2024-11-20	Problem dotyczy również Produkcji. Należy uczulić i kontrolować pracę Mistrzów. Instrukcja PP  nie została zaktualizowana.	f
7	1	\N	W razie konieczności należy zmienić instrukcję.	f
8	1	2024-12-02	W dalszym ciągu PW wystawia Kontroler Jakości	f
9	1	2024-11-30	Tuleje i tłoki nie zostały przypisane Mistrzowi.	f
10	1	\N	Analiza procesu i wymagań klienta, dostosowanie zaplecza technicznego bądź zmiana dokumentacji.	f
11	1	2024-05-19	\N	f
12	1	2024-09-15	\N	f
13	1	2024-07-30	\N	f
14	1	2024-10-10	\N	f
15	1	2024-11-20	Problem dotyczy również Produkcji. Należy uczulić i kontrolować pracę Mistrzów. Instrukcja PP  nie została zaktualizowana.	f
16	1	\N	W razie konieczności należy zmienić instrukcję.	f
17	1	2024-12-02	W dalszym ciągu PW wystawia Kontroler Jakości	f
18	1	2024-11-30	Tuleje i tłoki nie zostały przypisane Mistrzowi.	f
19	1	\N	Analiza procesu i wymagań klienta, dostosowanie zaplecza technicznego bądź zmiana dokumentacji.	f
20	2	2024-10-07	Zatwierdzone	f
21	2	\N	-	f
22	2	\N	-	f
23	2	2024-11-10	-	f
24	2	2024-11-10	Zatwierdzone	f
25	2	\N	-	f
26	2	\N	-	f
27	2	\N	-	f
28	2	\N	-	f
29	2	\N	-	f
30	2	\N	-	f
31	2	\N	-	f
32	2	\N	-	f
33	2	\N	-	f
34	2	\N	-	f
35	2	\N	-	f
36	2	\N	-	f
37	2	\N	-	f
38	2	\N	-	f
39	2	\N	-	f
40	2	\N	-	f
41	2	\N	-	f
42	1	2025-01-31	\N	f
43	1	2025-01-31	\N	f
44	1	2025-01-31	\N	f
45	1	2025-01-31	\N	f
46	1	2025-01-12	\N	f
47	1	2025-02-05	\N	f
48	1	2025-01-25	\N	f
49	1	2025-02-05	\N	f
50	1	2025-01-18	\N	f
51	1	2025-01-18	\N	f
52	1	2025-02-05	\N	f
53	1	2025-02-01	\N	f
54	1	\N	\N	f
55	1	2025-02-18	\N	f
56	1	2025-01-28	\N	f
57	1	2025-01-20	Pracownicy powinni zostać przeszkoleni, niepotrzebnie piaskowane wyroby	f
58	1	2025-01-20	Pracownicy powinni zostać przeszkoleni, niepotrzebnie piaskowane wyroby	f
59	1	2025-01-20	Pracownicy powinni zostać przeszkoleni, niepotrzebnie piaskowane wyroby	f
60	1	2025-02-05	\N	f
61	1	2025-01-30	\N	f
62	1	2025-01-23	Personel powienien być przeszkolony z czytania rysunków.	f
63	1	2025-01-30	\N	f
64	1	2025-01-30	\N	f
65	1	2025-01-25	\N	f
66	1	2025-04-15	\N	f
67	1	2025-02-05	\N	f
68	1	2025-02-05	\N	f
69	1	2025-04-10	\N	f
70	1	2025-04-14	Przyrząd wstepnie działa	f
71	1	2025-02-07	\N	f
72	1	2025-02-08	\N	f
73	1	2025-03-20	\N	f
74	1	2025-02-06	\N	f
75	1	2025-03-10	\N	f
76	1	2025-03-10	\N	f
77	1	2025-03-10	\N	f
78	1	2025-04-10	\N	f
79	1	2025-03-10	\N	f
80	1	2025-03-14	\N	f
81	1	2025-04-14	\N	f
82	1	2025-03-10	\N	f
83	1	2025-03-10	\N	f
84	1	2025-03-10	\N	f
85	1	2025-03-10	\N	f
86	1	2025-02-24	\N	f
87	1	2025-03-15	\N	f
88	1	2025-03-15	\N	f
89	1	2025-03-15	\N	f
90	1	2025-03-15	dokument	f
91	1	2025-03-15	dokument	f
92	1	2025-02-26	\N	f
93	1	2025-03-15	\N	f
94	1	2025-03-15	\N	f
95	1	2025-03-15	\N	f
96	1	2025-03-15	\N	f
97	1	2025-03-15	\N	f
98	1	2025-04-11	\N	f
99	1	2025-03-16	\N	f
100	1	2025-03-24	\N	f
101	1	2025-03-24	\N	f
102	1	2025-03-30	\N	f
103	1	2025-04-07	\N	f
104	1	2025-04-05	\N	f
105	1	2025-04-05	\N	f
106	2	\N	\N	f
107	2	2025-03-30	\N	f
108	2	2025-03-30	\N	f
109	2	2025-03-30	\N	f
110	2	2025-02-02	\N	f
111	2	2025-03-30	\N	f
112	2	2025-03-30	\N	f
113	2	2025-03-30	\N	f
114	2	2025-03-30	\N	f
115	2	2025-03-30	\N	f
116	2	2025-03-30	\N	f
117	2	2025-03-30	\N	f
118	2	2025-03-30	\N	f
119	2	2025-04-01	\N	f
120	2	2025-03-30	\N	f
121	2	2025-02-15	\N	f
122	2	2025-02-28	\N	f
123	2	2025-03-30	\N	f
124	2	2025-03-30	\N	f
125	2	2025-04-01	\N	f
126	2	\N	Informacje o kliencie, cechowaniu, malowaniu wychodzące z marketingu.	f
127	2	2025-04-01	\N	f
128	2	2025-04-01	\N	f
129	2	2025-04-01	\N	f
130	2	2025-03-30	\N	f
131	2	\N	\N	f
132	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
133	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
134	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
135	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
136	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
137	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
138	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
139	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
140	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
141	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
142	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
143	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
144	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
145	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
146	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
147	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
148	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
149	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
150	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
151	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
152	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
153	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
154	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
155	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
156	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
157	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
158	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
159	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
160	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
161	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
162	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
163	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
164	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
165	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
166	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
167	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
168	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
169	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
170	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
171	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
172	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
173	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
174	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
175	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
176	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
177	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
178	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
179	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
180	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
181	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
182	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
183	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
184	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
185	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
186	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
187	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
188	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
189	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
190	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
191	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
192	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
193	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
194	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
195	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
196	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
197	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
198	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
199	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
200	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
201	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
202	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
203	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
204	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
205	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
206	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
207	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
208	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
209	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
210	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
211	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
212	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
213	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
214	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
215	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
216	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
217	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
218	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
219	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
220	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
221	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
222	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
223	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
224	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
225	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
226	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
227	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
228	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
229	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
230	2	\N	Wciąż wykrywane są pojedyncze przypadki odprysków.	f
\.


--
-- TOC entry 5048 (class 0 OID 19184)
-- Dependencies: 251
-- Data for Name: sprawdzanie_dzialan_opis_problemu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sprawdzanie_dzialan_opis_problemu (sprawdzanie_dzialan_id, opis_problemu_id) FROM stdin;
42	201
42	226
42	361
42	417
43	201
43	226
43	361
43	417
44	201
44	226
44	361
44	417
45	201
45	226
45	361
45	417
46	260
47	231
47	324
47	397
47	432
47	457
47	529
48	213
48	420
49	231
49	324
49	397
49	432
49	457
49	529
50	154
50	509
51	154
51	509
52	231
52	324
52	397
52	432
52	457
52	529
53	194
55	197
56	398
57	301
57	369
58	301
58	369
59	301
59	369
60	231
60	324
60	397
60	432
60	457
60	529
61	129
61	174
61	273
62	389
63	129
63	174
63	273
64	129
64	174
64	273
65	213
65	420
67	231
67	324
67	397
67	432
67	457
67	529
68	231
68	324
68	397
68	432
68	457
68	529
69	233
69	449
70	356
71	425
73	152
74	163
75	176
75	251
75	295
75	310
75	334
75	409
75	528
76	176
76	251
76	295
76	310
76	334
76	409
76	528
77	176
77	251
77	295
77	310
77	334
77	409
77	528
78	233
78	449
79	176
79	251
79	295
79	310
79	334
79	409
79	528
80	465
81	356
82	176
82	251
82	295
82	310
82	334
82	409
82	528
83	176
83	251
83	295
83	310
83	334
83	409
83	528
84	176
84	251
84	295
84	310
84	334
84	409
84	528
85	176
85	251
85	295
85	310
85	334
85	409
85	528
86	363
87	147
87	170
87	191
87	193
87	249
87	258
87	309
87	372
87	442
87	540
88	147
88	170
88	191
88	193
88	249
88	258
88	309
88	372
88	442
88	540
89	147
89	170
89	191
89	193
89	249
89	258
89	309
89	372
89	442
89	540
90	147
90	170
90	191
90	193
90	249
90	258
90	309
90	372
90	442
90	540
91	147
91	170
91	191
91	193
91	249
91	258
91	309
91	372
91	442
91	540
92	135
93	147
93	170
93	191
93	193
93	249
93	258
93	309
93	372
93	442
93	540
94	147
94	170
94	191
94	193
94	249
94	258
94	309
94	372
94	442
94	540
95	147
95	170
95	191
95	193
95	249
95	258
95	309
95	372
95	442
95	540
96	147
96	170
96	191
96	193
96	249
96	258
96	309
96	372
96	442
96	540
97	147
97	170
97	191
97	193
97	249
97	258
97	309
97	372
97	442
97	540
98	237
99	534
100	336
100	469
101	336
101	469
102	127
103	500
104	132
104	269
105	132
105	269
107	154
107	174
107	194
107	197
107	201
107	213
107	226
107	231
107	324
107	363
107	417
107	420
107	457
107	509
107	529
108	154
108	174
108	194
108	197
108	201
108	213
108	226
108	231
108	324
108	363
108	417
108	420
108	457
108	509
108	529
109	154
109	174
109	194
109	197
109	201
109	213
109	226
109	231
109	324
109	363
109	417
109	420
109	457
109	509
109	529
110	260
111	154
111	174
111	194
111	197
111	201
111	213
111	226
111	231
111	324
111	363
111	417
111	420
111	457
111	509
111	529
112	154
112	174
112	194
112	197
112	201
112	213
112	226
112	231
112	324
112	363
112	417
112	420
112	457
112	509
112	529
113	154
113	174
113	194
113	197
113	201
113	213
113	226
113	231
113	324
113	363
113	417
113	420
113	457
113	509
113	529
114	154
114	174
114	194
114	197
114	201
114	213
114	226
114	231
114	324
114	363
114	417
114	420
114	457
114	509
114	529
115	154
115	174
115	194
115	197
115	201
115	213
115	226
115	231
115	324
115	363
115	417
115	420
115	457
115	509
115	529
116	154
116	174
116	194
116	197
116	201
116	213
116	226
116	231
116	324
116	363
116	417
116	420
116	457
116	509
116	529
117	154
117	174
117	194
117	197
117	201
117	213
117	226
117	231
117	324
117	363
117	417
117	420
117	457
117	509
117	529
118	154
118	174
118	194
118	197
118	201
118	213
118	226
118	231
118	324
118	363
118	417
118	420
118	457
118	509
118	529
119	163
119	398
119	425
119	432
120	154
120	174
120	194
120	197
120	201
120	213
120	226
120	231
120	324
120	363
120	417
120	420
120	457
120	509
120	529
121	273
122	129
123	154
123	174
123	194
123	197
123	201
123	213
123	226
123	231
123	324
123	363
123	417
123	420
123	457
123	509
123	529
124	154
124	174
124	194
124	197
124	201
124	213
124	226
124	231
124	324
124	363
124	417
124	420
124	457
124	509
124	529
125	163
125	398
125	425
125	432
127	163
127	398
127	425
127	432
128	163
128	398
128	425
128	432
129	163
129	398
129	425
129	432
130	154
130	174
130	194
130	197
130	201
130	213
130	226
130	231
130	324
130	363
130	417
130	420
130	457
130	509
130	529
57	82
57	87
57	88
58	82
58	87
58	88
59	82
59	87
59	88
70	84
81	84
98	83
98	93
98	97
98	106
98	113
98	120
\.


--
-- TOC entry 5049 (class 0 OID 19187)
-- Dependencies: 252
-- Data for Name: sprawdzanie_dzialan_pracownik; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sprawdzanie_dzialan_pracownik (sprawdzanie_dzialan_id, pracownik_id) FROM stdin;
2	8
3	8
4	8
5	8
6	8
8	8
9	8
11	8
12	8
13	8
14	8
15	8
17	8
18	8
20	8
23	8
24	8
42	8
43	8
44	8
45	8
46	8
47	8
48	8
49	8
50	8
51	8
52	8
53	8
55	8
56	8
57	8
58	8
59	8
60	8
61	8
62	8
63	8
64	8
65	8
66	8
67	8
68	8
69	8
70	8
71	8
72	8
73	8
74	8
75	8
76	8
77	8
78	8
79	8
80	8
81	8
82	8
83	8
84	8
85	8
86	8
87	8
88	8
89	8
90	8
91	8
92	8
93	8
94	8
95	8
96	8
97	8
98	8
99	8
100	8
101	8
102	8
103	8
104	8
105	8
107	8
108	8
109	8
110	8
111	8
112	8
113	8
114	8
115	8
116	8
117	8
118	8
119	8
120	8
121	8
122	8
123	8
124	8
125	8
127	8
128	8
129	8
130	8
\.


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 220
-- Name: audyt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audyt_id_seq', 80, true);


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 222
-- Name: detal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detal_id_seq', 383, true);


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 224
-- Name: dzialanie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dzialanie_id_seq', 836, true);


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 228
-- Name: firma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.firma_id_seq', 86, true);


--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 232
-- Name: opis_problemu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opis_problemu_id_seq', 635, true);


--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 235
-- Name: pracownik_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pracownik_id_seq', 70, true);


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 238
-- Name: reklamacja_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reklamacja_id_seq', 681, true);


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 240
-- Name: slownik_dzial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slownik_dzial_id_seq', 10, true);


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 242
-- Name: slownik_dzialanie_typ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slownik_dzialanie_typ_id_seq', 2, true);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 244
-- Name: slownik_sprawdzanie_typ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slownik_sprawdzanie_typ_id_seq', 2, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 246
-- Name: slownik_typ_audytu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slownik_typ_audytu_id_seq', 2, true);


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 248
-- Name: slownik_typ_reklamacji_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slownik_typ_reklamacji_id_seq', 3, true);


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 250
-- Name: sprawdzanie_dzialan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sprawdzanie_dzialan_id_seq', 230, true);


--
-- TOC entry 4777 (class 2606 OID 19238)
-- Name: audyt audyt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audyt
    ADD CONSTRAINT audyt_pkey PRIMARY KEY (id);


--
-- TOC entry 4779 (class 2606 OID 19240)
-- Name: detal detal_kod_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detal
    ADD CONSTRAINT detal_kod_key UNIQUE (kod);


--
-- TOC entry 4781 (class 2606 OID 19242)
-- Name: detal detal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detal
    ADD CONSTRAINT detal_pkey PRIMARY KEY (id);


--
-- TOC entry 4787 (class 2606 OID 19244)
-- Name: dzialanie_opis_problemu dzialanie_opis_problemu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_opis_problemu
    ADD CONSTRAINT dzialanie_opis_problemu_pkey PRIMARY KEY (dzialanie_id, opis_problemu_id);


--
-- TOC entry 4784 (class 2606 OID 19246)
-- Name: dzialanie dzialanie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie
    ADD CONSTRAINT dzialanie_pkey PRIMARY KEY (id);


--
-- TOC entry 4789 (class 2606 OID 19248)
-- Name: dzialanie_pracownik dzialanie_pracownik_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_pracownik
    ADD CONSTRAINT dzialanie_pracownik_pkey PRIMARY KEY (dzialanie_id, pracownik_id);


--
-- TOC entry 4791 (class 2606 OID 19250)
-- Name: firma firma_kod_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.firma
    ADD CONSTRAINT firma_kod_key UNIQUE (kod);


--
-- TOC entry 4793 (class 2606 OID 19252)
-- Name: firma firma_nazwa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.firma
    ADD CONSTRAINT firma_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 4795 (class 2606 OID 19254)
-- Name: firma firma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.firma
    ADD CONSTRAINT firma_pkey PRIMARY KEY (id);


--
-- TOC entry 4801 (class 2606 OID 19256)
-- Name: opis_problemu_audyt opis_problemu_audyt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_audyt
    ADD CONSTRAINT opis_problemu_audyt_pkey PRIMARY KEY (opis_problemu_id, audyt_id);


--
-- TOC entry 4803 (class 2606 OID 19258)
-- Name: opis_problemu_dzial opis_problemu_dzial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_dzial
    ADD CONSTRAINT opis_problemu_dzial_pkey PRIMARY KEY (opis_problemu_id, dzial_id);


--
-- TOC entry 4799 (class 2606 OID 19260)
-- Name: opis_problemu opis_problemu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu
    ADD CONSTRAINT opis_problemu_pkey PRIMARY KEY (id);


--
-- TOC entry 4805 (class 2606 OID 19262)
-- Name: opis_problemu_reklamacja opis_problemu_reklamacja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_reklamacja
    ADD CONSTRAINT opis_problemu_reklamacja_pkey PRIMARY KEY (opis_problemu_id, reklamacja_id);


--
-- TOC entry 4807 (class 2606 OID 19264)
-- Name: pracownik pracownik_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownik
    ADD CONSTRAINT pracownik_pkey PRIMARY KEY (id);


--
-- TOC entry 4809 (class 2606 OID 19266)
-- Name: pracownik pracownik_telefon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownik
    ADD CONSTRAINT pracownik_telefon_key UNIQUE (telefon);


--
-- TOC entry 4819 (class 2606 OID 19268)
-- Name: reklamacja_detal reklamacja_detal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja_detal
    ADD CONSTRAINT reklamacja_detal_pkey PRIMARY KEY (reklamacja_id, detal_id);


--
-- TOC entry 4814 (class 2606 OID 19270)
-- Name: reklamacja reklamacja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja
    ADD CONSTRAINT reklamacja_pkey PRIMARY KEY (id);


--
-- TOC entry 4816 (class 2606 OID 19272)
-- Name: reklamacja reklamacja_zlecenie_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja
    ADD CONSTRAINT reklamacja_zlecenie_key UNIQUE (zlecenie);


--
-- TOC entry 4821 (class 2606 OID 19274)
-- Name: slownik_dzial slownik_dzial_nazwa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzial
    ADD CONSTRAINT slownik_dzial_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 4823 (class 2606 OID 19276)
-- Name: slownik_dzial slownik_dzial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzial
    ADD CONSTRAINT slownik_dzial_pkey PRIMARY KEY (id);


--
-- TOC entry 4825 (class 2606 OID 19278)
-- Name: slownik_dzialanie_typ slownik_dzialanie_typ_nazwa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzialanie_typ
    ADD CONSTRAINT slownik_dzialanie_typ_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 4827 (class 2606 OID 19280)
-- Name: slownik_dzialanie_typ slownik_dzialanie_typ_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_dzialanie_typ
    ADD CONSTRAINT slownik_dzialanie_typ_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 19282)
-- Name: slownik_sprawdzanie_typ slownik_sprawdzanie_typ_kod_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_sprawdzanie_typ
    ADD CONSTRAINT slownik_sprawdzanie_typ_kod_key UNIQUE (kod);


--
-- TOC entry 4831 (class 2606 OID 19284)
-- Name: slownik_sprawdzanie_typ slownik_sprawdzanie_typ_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_sprawdzanie_typ
    ADD CONSTRAINT slownik_sprawdzanie_typ_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 19286)
-- Name: slownik_typ_audytu slownik_typ_audytu_nazwa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_audytu
    ADD CONSTRAINT slownik_typ_audytu_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 4835 (class 2606 OID 19288)
-- Name: slownik_typ_audytu slownik_typ_audytu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_audytu
    ADD CONSTRAINT slownik_typ_audytu_pkey PRIMARY KEY (id);


--
-- TOC entry 4837 (class 2606 OID 19290)
-- Name: slownik_typ_reklamacji slownik_typ_reklamacji_nazwa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_reklamacji
    ADD CONSTRAINT slownik_typ_reklamacji_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 4839 (class 2606 OID 19292)
-- Name: slownik_typ_reklamacji slownik_typ_reklamacji_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slownik_typ_reklamacji
    ADD CONSTRAINT slownik_typ_reklamacji_pkey PRIMARY KEY (id);


--
-- TOC entry 4844 (class 2606 OID 19294)
-- Name: sprawdzanie_dzialan_opis_problemu sprawdzanie_dzialan_opis_problemu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_opis_problemu
    ADD CONSTRAINT sprawdzanie_dzialan_opis_problemu_pkey PRIMARY KEY (sprawdzanie_dzialan_id, opis_problemu_id);


--
-- TOC entry 4842 (class 2606 OID 19296)
-- Name: sprawdzanie_dzialan sprawdzanie_dzialan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan
    ADD CONSTRAINT sprawdzanie_dzialan_pkey PRIMARY KEY (id);


--
-- TOC entry 4846 (class 2606 OID 19298)
-- Name: sprawdzanie_dzialan_pracownik sprawdzanie_dzialan_pracownik_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_pracownik
    ADD CONSTRAINT sprawdzanie_dzialan_pracownik_pkey PRIMARY KEY (sprawdzanie_dzialan_id, pracownik_id);


--
-- TOC entry 4782 (class 1259 OID 19299)
-- Name: idx_detal_typ; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detal_typ ON public.detal USING btree (typ);


--
-- TOC entry 4785 (class 1259 OID 19300)
-- Name: idx_dzialanie_typ; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dzialanie_typ ON public.dzialanie USING btree (typ_id);


--
-- TOC entry 4796 (class 1259 OID 19301)
-- Name: idx_opis_problemu_miejsce; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_opis_problemu_miejsce ON public.opis_problemu USING btree (miejsce_powstania);


--
-- TOC entry 4797 (class 1259 OID 19302)
-- Name: idx_opis_problemu_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_opis_problemu_status ON public.opis_problemu USING btree (status);


--
-- TOC entry 4817 (class 1259 OID 19303)
-- Name: idx_reklamacja_detal; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reklamacja_detal ON public.reklamacja_detal USING btree (detal_id);


--
-- TOC entry 4810 (class 1259 OID 19304)
-- Name: idx_reklamacja_firma; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reklamacja_firma ON public.reklamacja USING btree (firma_id);


--
-- TOC entry 4811 (class 1259 OID 19305)
-- Name: idx_reklamacja_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reklamacja_status ON public.reklamacja USING btree (status);


--
-- TOC entry 4812 (class 1259 OID 19306)
-- Name: idx_reklamacja_typ; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reklamacja_typ ON public.reklamacja USING btree (typ_id);


--
-- TOC entry 4840 (class 1259 OID 19307)
-- Name: idx_sprawdzanie_typ; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprawdzanie_typ ON public.sprawdzanie_dzialan USING btree (typ_id);


--
-- TOC entry 4847 (class 2606 OID 19308)
-- Name: audyt audyt_firma_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audyt
    ADD CONSTRAINT audyt_firma_id_fkey FOREIGN KEY (firma_id) REFERENCES public.firma(id);


--
-- TOC entry 4848 (class 2606 OID 19313)
-- Name: audyt audyt_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audyt
    ADD CONSTRAINT audyt_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.slownik_typ_audytu(id);


--
-- TOC entry 4850 (class 2606 OID 19318)
-- Name: dzialanie_opis_problemu dzialanie_opis_problemu_dzialanie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_opis_problemu
    ADD CONSTRAINT dzialanie_opis_problemu_dzialanie_id_fkey FOREIGN KEY (dzialanie_id) REFERENCES public.dzialanie(id) ON DELETE CASCADE;


--
-- TOC entry 4851 (class 2606 OID 19323)
-- Name: dzialanie_opis_problemu dzialanie_opis_problemu_opis_problemu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_opis_problemu
    ADD CONSTRAINT dzialanie_opis_problemu_opis_problemu_id_fkey FOREIGN KEY (opis_problemu_id) REFERENCES public.opis_problemu(id) ON DELETE CASCADE;


--
-- TOC entry 4852 (class 2606 OID 19328)
-- Name: dzialanie_pracownik dzialanie_pracownik_dzialanie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_pracownik
    ADD CONSTRAINT dzialanie_pracownik_dzialanie_id_fkey FOREIGN KEY (dzialanie_id) REFERENCES public.dzialanie(id) ON DELETE CASCADE;


--
-- TOC entry 4853 (class 2606 OID 19333)
-- Name: dzialanie_pracownik dzialanie_pracownik_pracownik_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie_pracownik
    ADD CONSTRAINT dzialanie_pracownik_pracownik_id_fkey FOREIGN KEY (pracownik_id) REFERENCES public.pracownik(id);


--
-- TOC entry 4849 (class 2606 OID 19338)
-- Name: dzialanie dzialanie_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dzialanie
    ADD CONSTRAINT dzialanie_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.slownik_dzialanie_typ(id);


--
-- TOC entry 4854 (class 2606 OID 19343)
-- Name: opis_problemu_audyt opis_problemu_audyt_audyt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_audyt
    ADD CONSTRAINT opis_problemu_audyt_audyt_id_fkey FOREIGN KEY (audyt_id) REFERENCES public.audyt(id) ON DELETE CASCADE;


--
-- TOC entry 4855 (class 2606 OID 19348)
-- Name: opis_problemu_audyt opis_problemu_audyt_opis_problemu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_audyt
    ADD CONSTRAINT opis_problemu_audyt_opis_problemu_id_fkey FOREIGN KEY (opis_problemu_id) REFERENCES public.opis_problemu(id) ON DELETE CASCADE;


--
-- TOC entry 4856 (class 2606 OID 19353)
-- Name: opis_problemu_dzial opis_problemu_dzial_dzial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_dzial
    ADD CONSTRAINT opis_problemu_dzial_dzial_id_fkey FOREIGN KEY (dzial_id) REFERENCES public.slownik_dzial(id);


--
-- TOC entry 4857 (class 2606 OID 19358)
-- Name: opis_problemu_dzial opis_problemu_dzial_opis_problemu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_dzial
    ADD CONSTRAINT opis_problemu_dzial_opis_problemu_id_fkey FOREIGN KEY (opis_problemu_id) REFERENCES public.opis_problemu(id) ON DELETE CASCADE;


--
-- TOC entry 4858 (class 2606 OID 19363)
-- Name: opis_problemu_reklamacja opis_problemu_reklamacja_opis_problemu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_reklamacja
    ADD CONSTRAINT opis_problemu_reklamacja_opis_problemu_id_fkey FOREIGN KEY (opis_problemu_id) REFERENCES public.opis_problemu(id) ON DELETE CASCADE;


--
-- TOC entry 4859 (class 2606 OID 19368)
-- Name: opis_problemu_reklamacja opis_problemu_reklamacja_reklamacja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opis_problemu_reklamacja
    ADD CONSTRAINT opis_problemu_reklamacja_reklamacja_id_fkey FOREIGN KEY (reklamacja_id) REFERENCES public.reklamacja(id) ON DELETE CASCADE;


--
-- TOC entry 4860 (class 2606 OID 19373)
-- Name: pracownik pracownik_dzial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownik
    ADD CONSTRAINT pracownik_dzial_id_fkey FOREIGN KEY (dzial_id) REFERENCES public.slownik_dzial(id);


--
-- TOC entry 4863 (class 2606 OID 19378)
-- Name: reklamacja_detal reklamacja_detal_detal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja_detal
    ADD CONSTRAINT reklamacja_detal_detal_id_fkey FOREIGN KEY (detal_id) REFERENCES public.detal(id) ON DELETE CASCADE;


--
-- TOC entry 4864 (class 2606 OID 19383)
-- Name: reklamacja_detal reklamacja_detal_reklamacja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja_detal
    ADD CONSTRAINT reklamacja_detal_reklamacja_id_fkey FOREIGN KEY (reklamacja_id) REFERENCES public.reklamacja(id) ON DELETE CASCADE;


--
-- TOC entry 4861 (class 2606 OID 19388)
-- Name: reklamacja reklamacja_firma_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja
    ADD CONSTRAINT reklamacja_firma_id_fkey FOREIGN KEY (firma_id) REFERENCES public.firma(id);


--
-- TOC entry 4862 (class 2606 OID 19393)
-- Name: reklamacja reklamacja_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reklamacja
    ADD CONSTRAINT reklamacja_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.slownik_typ_reklamacji(id);


--
-- TOC entry 4866 (class 2606 OID 19398)
-- Name: sprawdzanie_dzialan_opis_problemu sprawdzanie_dzialan_opis_problemu_opis_problemu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_opis_problemu
    ADD CONSTRAINT sprawdzanie_dzialan_opis_problemu_opis_problemu_id_fkey FOREIGN KEY (opis_problemu_id) REFERENCES public.opis_problemu(id) ON DELETE CASCADE;


--
-- TOC entry 4867 (class 2606 OID 19403)
-- Name: sprawdzanie_dzialan_opis_problemu sprawdzanie_dzialan_opis_problemu_sprawdzanie_dzialan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_opis_problemu
    ADD CONSTRAINT sprawdzanie_dzialan_opis_problemu_sprawdzanie_dzialan_id_fkey FOREIGN KEY (sprawdzanie_dzialan_id) REFERENCES public.sprawdzanie_dzialan(id) ON DELETE CASCADE;


--
-- TOC entry 4868 (class 2606 OID 19408)
-- Name: sprawdzanie_dzialan_pracownik sprawdzanie_dzialan_pracownik_pracownik_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_pracownik
    ADD CONSTRAINT sprawdzanie_dzialan_pracownik_pracownik_id_fkey FOREIGN KEY (pracownik_id) REFERENCES public.pracownik(id);


--
-- TOC entry 4869 (class 2606 OID 19413)
-- Name: sprawdzanie_dzialan_pracownik sprawdzanie_dzialan_pracownik_sprawdzanie_dzialan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan_pracownik
    ADD CONSTRAINT sprawdzanie_dzialan_pracownik_sprawdzanie_dzialan_id_fkey FOREIGN KEY (sprawdzanie_dzialan_id) REFERENCES public.sprawdzanie_dzialan(id) ON DELETE CASCADE;


--
-- TOC entry 4865 (class 2606 OID 19418)
-- Name: sprawdzanie_dzialan sprawdzanie_dzialan_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprawdzanie_dzialan
    ADD CONSTRAINT sprawdzanie_dzialan_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.slownik_sprawdzanie_typ(id);


-- Completed on 2025-06-16 22:31:26

--
-- PostgreSQL database dump complete
--

