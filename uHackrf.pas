unit uHackrf;

interface

const
  SAMPLES_PER_BLOCK = 8192;
  BYTES_PER_BLOCK = 16384;
  MAX_SWEEP_RANGES = 10;

type
  UInt32=Cardinal;
  PUint32=^Cardinal;
  hackrf_error = (
    HACKRF_SUCCESS = 0,
    HACKRF_TRUE = 1,
    HACKRF_ERROR_INVALID_PARAM = -2,
    HACKRF_ERROR_NOT_FOUND = -5,
    HACKRF_ERROR_BUSY = -6,
    HACKRF_ERROR_NO_MEM = -11,
    HACKRF_ERROR_LIBUSB = -1000,
    HACKRF_ERROR_THREAD = -1001,
    HACKRF_ERROR_STREAMING_THREAD_ERR = -1002,
    HACKRF_ERROR_STREAMING_STOPPED = -1003,
    HACKRF_ERROR_STREAMING_EXIT_CALLED = -1004,
    HACKRF_ERROR_USB_API_VERSION = -1005,
    HACKRF_ERROR_NOT_LAST_DEVICE = -2000,
    HACKRF_ERROR_OTHER = -9999
  );

  hackrf_board_id = (
    BOARD_ID_JELLYBEAN  = 0,
    BOARD_ID_JAWBREAKER = 1,
    BOARD_ID_HACKRF_ONE = 2,
    BOARD_ID_RAD1O = 3,
    BOARD_ID_INVALID = $FF
  );

  hackrf_usb_board_id = (
    USB_BOARD_ID_JAWBREAKER = $604B,
    USB_BOARD_ID_HACKRF_ONE = $6089,
    USB_BOARD_ID_RAD1O = $CC15,
    USB_BOARD_ID_INVALID = $FFFF
  );

  rf_path_filter = (
    RF_PATH_FILTER_BYPASS = 0,
    RF_PATH_FILTER_LOW_PASS = 1,
    RF_PATH_FILTER_HIGH_PASS = 2
  );

  operacake_ports = (
    OPERACAKE_PA1 = 0,
    OPERACAKE_PA2 = 1,
    OPERACAKE_PA3 = 2,
    OPERACAKE_PA4 = 3,
    OPERACAKE_PB1 = 4,
    OPERACAKE_PB2 = 5,
    OPERACAKE_PB3 = 6,
    OPERACAKE_PB4 = 7
  );

  sweep_style = (
    LINEAR = 0,
	  INTERLEAVED = 1
  );

  phackrf_device = ^hackrf_device;
  hackrf_device = record
  end;

  phackrf_transfer = ^hackrf_transfer;
  hackrf_transfer = record
    device: phackrf_device;
    buffer: PByte;
    buffer_length: Integer;
    valid_length: Integer;
    rx_ctx: Pointer;
    tx_ctx: Pointer;
  end;

  pread_partid_serialno_t = ^read_partid_serialno_t;
  read_partid_serialno_t = record
    part_id: array[0..1]of UInt32;
    serial_no: array[0..3]of UInt32;
  end;

  phackrf_device_list_t = ^hackrf_device_list_t;
  hackrf_device_list_t = record
    serial_numbers: PPAnsiChar;
    usb_board_ids: ^hackrf_usb_board_id;
    usb_device_index: PInteger;
    devicecount: Integer;
    usb_devices: PPointer;
    usb_devicecount: Integer;
  end;

  hackrf_sample_block_cb_fn = function(transfer: phackrf_transfer): Integer;  cdecl;

function hackrf_init(): Integer; cdecl;
function hackrf_exit(): Integer; cdecl;

//function hackrf_library_version(): PAnsiChar; cdecl;
//function hackrf_library_release(): PAnsiChar; cdecl;

//function hackrf_device_list(): phackrf_device_list_t; cdecl;
//function hackrf_device_list_open(list: phackrf_device_list_t; idx: Integer; var device: phackrf_device): Integer; cdecl;
//procedure hackrf_device_list_free(list: phackrf_device_list_t); cdecl;

function hackrf_open(var device: phackrf_device): Integer; cdecl;
//function hackrf_open_by_serial(const desired_serial_number: PAnsiChar; var device: phackrf_device): Integer; cdecl;
function hackrf_close(device: phackrf_device): Integer; cdecl;

function hackrf_start_rx(device: phackrf_device; callback: hackrf_sample_block_cb_fn; rx_ctx: Pointer): Integer; cdecl;
function hackrf_stop_rx(device: phackrf_device): Integer; cdecl;

function hackrf_start_tx(device: phackrf_device; callback: hackrf_sample_block_cb_fn; tx_ctx: Pointer): Integer; cdecl;
function hackrf_stop_tx(device: phackrf_device): Integer; cdecl;

(* return HACKRF_TRUE if success *)
function hackrf_is_streaming(device: phackrf_device): Integer; cdecl;

function hackrf_max2837_read(device: phackrf_device; register_number: Byte; value: PWord): Integer; cdecl;
function hackrf_max2837_write(device: phackrf_device; register_number: Byte; value: Word): Integer; cdecl;

function hackrf_si5351c_read(device: phackrf_device; register_number: Word; value: PWord): Integer; cdecl;
function hackrf_si5351c_write(device: phackrf_device; register_number: Word; value: Word): Integer; cdecl;

function hackrf_set_baseband_filter_bandwidth(device: phackrf_device; const bandwidth_hz: UInt32): Integer; cdecl;

function hackrf_rffc5071_read(device: phackrf_device; register_number: Word; value: PWord): Integer; cdecl;
function hackrf_rffc5071_write(device: phackrf_device; register_number: Word; value: Word): Integer; cdecl;

function hackrf_spiflash_erase(device: phackrf_device): Integer; cdecl;
function hackrf_spiflash_write(device: phackrf_device; const address: UInt32; const length: Word; const data: PByte): Integer; cdecl;
function hackrf_spiflash_read(device: phackrf_device; const address: UInt32; const length: Word; data: PByte): Integer; cdecl;
//function hackrf_spiflash_status(device: phackrf_device; data: PByte): Integer; cdecl;
//function hackrf_spiflash_clear_status(device: phackrf_device): Integer; cdecl;

(* device will need to be reset after hackrf_cpld_write *)
function hackrf_cpld_write(device: phackrf_device; const data: PByte; const total_length: UInt32): Integer; cdecl;

function hackrf_board_id_read(device: phackrf_device; value: PByte): Integer; cdecl;
function hackrf_version_string_read(device: phackrf_device; version: PAnsiChar; length: Byte): Integer; cdecl;
//function hackrf_usb_api_version_read(device: phackrf_device; version: PWord): Integer; cdecl;

function hackrf_set_freq(device: phackrf_device; const freq_hz: UInt64): Integer; cdecl;
function hackrf_set_freq_explicit(device: phackrf_device; const if_freq_hz: UInt64;
  const lo_freq_hz: UInt64; path: rf_path_filter): Integer; cdecl;

(* currently 8-20Mhz - either as a fraction, i.e. freq 20000000hz divider 2 -> 10Mhz or as plain old 10000000hz (double)
	preferred rates are 8, 10, 12.5, 16, 20Mhz due to less jitter *)
function hackrf_set_sample_rate_manual(device: phackrf_device; const freq_hz: UInt32; const divider: UInt32): Integer; cdecl;
function hackrf_set_sample_rate(device: phackrf_device; const freq_hz: Double): Integer; cdecl;

(* external amp, bool on/off *)
function hackrf_set_amp_enable(device: phackrf_device; value: Byte): Integer; cdecl;

function hackrf_board_partid_serialno_read(device: phackrf_device; read_partid_serialno: pread_partid_serialno_t): Integer; cdecl;

(* range 0-40 step 8d, IF gain in osmosdr  *)
function hackrf_set_lna_gain(device: phackrf_device; value: UInt32): Integer; cdecl;

(* range 0-62 step 2db, BB gain in osmosdr *)
function hackrf_set_vga_gain(device: phackrf_device; value: UInt32): Integer; cdecl;

(* range 0-47 step 1db *)
function hackrf_set_txvga_gain(device: phackrf_device; value: UInt32): Integer; cdecl;

(* antenna port power control *)
function hackrf_set_antenna_enable(device: phackrf_device; const value: Byte): Integer; cdecl;

function hackrf_error_name(errcode: hackrf_error): PAnsiChar; cdecl;
function hackrf_board_id_name(board_id: hackrf_board_id): PAnsiChar; cdecl;
//function hackrf_usb_board_id_name(usb_board_id: hackrf_usb_board_id): PAnsiChar; cdecl;
function hackrf_filter_path_name(const path: rf_path_filter): PAnsiChar; cdecl;

(* Compute nearest freq for bw filter (manual filter) *)
function hackrf_compute_baseband_filter_bw_round_down_lt(const bandwidth_hz: UInt32): UInt32; cdecl;
(* Compute best default value depending on sample rate (auto filter) *)
function hackrf_compute_baseband_filter_bw(const bandwidth_hz: UInt32): UInt32; cdecl;

(* All features below require USB API version 0x1002 or higher) *)

(* set hardware sync mode *)
//function hackrf_set_hw_sync_mode(device: phackrf_device; const value: Byte): Integer; cdecl;

(* Start sweep mode *)
{function hackrf_init_sweep(device: phackrf_device; const frequency_list: PWord;
  const num_ranges: Integer; const num_bytes: UInt32; const step_width: UInt32;
  const offset: UInt32; const style: sweep_style): Integer; cdecl;
}
(* Operacake functions *)
//function hackrf_get_operacake_boards(device: phackrf_device; boards: PByte): Integer; cdecl;
{function hackrf_set_operacake_ports(device: phackrf_device; address: Byte;
  port_a: Byte; port_b: Byte): Integer; cdecl;
 }
//function hackrf_reset(device: phackrf_device): Integer; cdecl;

//function hackrf_set_operacake_ranges(device: phackrf_device; ranges: PByte; num_ranges: Byte): Integer; cdecl;

//function hackrf_set_clkout_enable(device: phackrf_device; const value: Byte): Integer; cdecl;

//function hackrf_operacake_gpio_test(device: phackrf_device; address: Byte; test_result: PWord): Integer; cdecl;

//function hackrf_cpld_checksum(device: phackrf_device; crc: PUint32): Integer; cdecl;

implementation

const
  HACKRF_DLL = 'uhackrf.dll';

  function hackrf_init; external HACKRF_DLL;
  function hackrf_exit; external HACKRF_DLL;
//function hackrf_library_version; external HACKRF_DLL;
//function hackrf_library_release; external HACKRF_DLL;
//function hackrf_device_list; external HACKRF_DLL;
//function hackrf_device_list_open; external HACKRF_DLL;
//procedure hackrf_device_list_free; external HACKRF_DLL;
  function hackrf_open; external HACKRF_DLL;
//function hackrf_open_by_serial; external HACKRF_DLL;
  function hackrf_close; external HACKRF_DLL;
  function hackrf_start_rx; external HACKRF_DLL;
  function hackrf_stop_rx; external HACKRF_DLL;
  function hackrf_start_tx; external HACKRF_DLL;
  function hackrf_stop_tx; external HACKRF_DLL;
  function hackrf_is_streaming; external HACKRF_DLL;
  function hackrf_max2837_read; external HACKRF_DLL;
  function hackrf_max2837_write; external HACKRF_DLL;
  function hackrf_si5351c_read; external HACKRF_DLL;
  function hackrf_si5351c_write; external HACKRF_DLL;
  function hackrf_set_baseband_filter_bandwidth; external HACKRF_DLL;
  function hackrf_rffc5071_read; external HACKRF_DLL;
  function hackrf_rffc5071_write; external HACKRF_DLL;
  function hackrf_spiflash_erase; external HACKRF_DLL;
  function hackrf_spiflash_write; external HACKRF_DLL;
  function hackrf_spiflash_read; external HACKRF_DLL;
//function hackrf_spiflash_status; external HACKRF_DLL;
//function hackrf_spiflash_clear_status; external HACKRF_DLL;
  function hackrf_cpld_write; external HACKRF_DLL;
  function hackrf_board_id_read; external HACKRF_DLL;
  function hackrf_version_string_read; external HACKRF_DLL;
//function hackrf_usb_api_version_read; external HACKRF_DLL;
  function hackrf_set_freq; external HACKRF_DLL;
  function hackrf_set_freq_explicit; external HACKRF_DLL;
  function hackrf_set_sample_rate_manual; external HACKRF_DLL;
  function hackrf_set_sample_rate; external HACKRF_DLL;
  function hackrf_set_amp_enable; external HACKRF_DLL;
  function hackrf_board_partid_serialno_read; external HACKRF_DLL;
  function hackrf_set_lna_gain; external HACKRF_DLL;
  function hackrf_set_vga_gain; external HACKRF_DLL;
  function hackrf_set_txvga_gain; external HACKRF_DLL;
  function hackrf_set_antenna_enable; external HACKRF_DLL;
  function hackrf_error_name; external HACKRF_DLL;
  function hackrf_board_id_name; external HACKRF_DLL;
//function hackrf_usb_board_id_name; external HACKRF_DLL;
  function hackrf_filter_path_name; external HACKRF_DLL;
  function hackrf_compute_baseband_filter_bw_round_down_lt; external HACKRF_DLL;
  function hackrf_compute_baseband_filter_bw; external HACKRF_DLL;
//function hackrf_set_hw_sync_mode; external HACKRF_DLL;
//function hackrf_init_sweep; external HACKRF_DLL;
//function hackrf_get_operacake_boards; external HACKRF_DLL;
//function hackrf_set_operacake_ports; external HACKRF_DLL;
//function hackrf_reset; external HACKRF_DLL;
//function hackrf_set_operacake_ranges; external HACKRF_DLL;
//function hackrf_set_clkout_enable; external HACKRF_DLL;
//function hackrf_operacake_gpio_test; external HACKRF_DLL;
//function hackrf_cpld_checksum; external HACKRF_DLL;

end.
