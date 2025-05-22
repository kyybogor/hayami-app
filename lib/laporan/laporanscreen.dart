import 'package:flutter/material.dart';
import 'package:hayami_app/Dashboard/dashboardscreen.dart';
import 'package:hayami_app/inventori/pergerakanstokgudang.dart';
import 'package:hayami_app/inventori/pergerakanstokinventori.dart';
import 'package:hayami_app/inventori/ringkasaninventori.dart';
import 'package:hayami_app/inventori/ringkasanstokgudang.dart';
import 'package:hayami_app/laporan/aruskasscreen.dart';
import 'package:hayami_app/laporan/biayaperkontak.dart';
import 'package:hayami_app/laporan/bukubesar.dart';
import 'package:hayami_app/laporan/jurnal.dart';
import 'package:hayami_app/laporan/penjualan/detailpenjualan.dart';
import 'package:hayami_app/laporan/hutangpiutangperkontak.dart';
import 'package:hayami_app/laporan/labarugi.dart';
import 'package:hayami_app/laporan/neracalaporanscreen.dart';
import 'package:hayami_app/laporan/penjualan/pelunasanpembayarantagihan.dart';
import 'package:hayami_app/laporan/penjualan/pendapatanperpelanggan.dart';
import 'package:hayami_app/laporan/penjualan/penjualanperkategori.dart';
import 'package:hayami_app/laporan/penjualan/penjualanperperiode.dart';
import 'package:hayami_app/laporan/penjualan/penjualanperproduk.dart';
import 'package:hayami_app/laporan/penjualan/penjualanprodukperpelanggan.dart';
import 'package:hayami_app/laporan/penjualan/umurpiutang.dart';
import 'package:hayami_app/laporan/perubahanmodal.dart';
import 'package:hayami_app/laporan/penjualan/profitabilitas.dart';
import 'package:hayami_app/laporan/ringkasan_bank.dart';
import 'package:hayami_app/laporan/ringkasaneksekutif.dart';
import 'package:hayami_app/laporan/penjualan/tagihanpelanggan.dart';
import 'package:hayami_app/laporan/trialbalance.dart';
import 'package:hayami_app/laporanAssetTetap/detailLaporanAset.dart';
import 'package:hayami_app/laporanAssetTetap/pelepasanaset.dart';
import 'package:hayami_app/laporanAssetTetap/ringkasanasset.dart';
import 'package:hayami_app/pajak/pajakpemotongan.dart';
import 'package:hayami_app/pajak/pajakpenjualan.dart';
import 'package:hayami_app/laporan/pembelianperperiode.dart';
import 'package:hayami_app/laporan/pembelianperproduk.dart';

class LaporanPage extends StatelessWidget {
  final Map<String, List<String>> laporanKategori = {
    "Finansial": [
      "Neraca",
      "Arus Kas",
      "Laba Rugi",
      "Perubahan Modal",
      "Ringkasan Eksekutif",
      "Hutang Piutang per Kontak",
    ],
    "Akuntansi": [
      "Ringkasan Bank",
      "Buku Besar",
      "Jurnal",
      "Trial Balance",
    ],
    "Penjualan": [
      "Detail Penjualan",
      "Umur Piutang",
      "Tagihan Pelanggan",
      "Profibilitas Produk",
      "Pendapatan per Pelanggan",
      "Penjualan per Kategori Produk",
      "Penjualan per Produk",
      "Pemesanan per Produk",
      "Penjualan per Sales Person",
      "Pengiriman Penjualan",
      "Ongkos Kirim per Ekspedisi",
      "Pelunasan Pembayaran Tagihan",
      "Penjualan Produk per Pelanggan",
      "Penjualan per Periode",
    ],
    "Pembelian": [
      "Detail Pembelian",
      "Umur Hutang",
      "Tagihan Vendor",
      "Pembelian per Produk",
      "Pembelian per Vendor",
      "Pengiriman Pembelian",
      "Pelunasan Pembayaran Tagihan Pembelian",
      "Pembelian Produk per Vendor",
      "Pembelian per Periode",
    ],
    "Biaya": [
      "Biaya per Kontak",
      "Detil Klaim Biaya",
    ],
    "Pajak": [
      "Pajak Penjualan",
      "Pajak Pemotongan",
    ],
    "Inventori": [
      "Ringkasan Inventori",
      "Pergerakan Stok Inventori",
      "Ringkasan Stok Gudang",
      "Pergerakan Stok Gudang",
      "Laporan Produksi",
      "Laporan Transfer Gudang",
      "Laporan Mutasi Nomor Seri",
      "Laporan Stok Nomor Seri per Gudang",
      "Laporan Nomor Produksi Segera Kadaluarsa",
      "Laporan Sisa Umur Nomor Produksi",
      "Laporan Riwayat Nomor Seri",
    ],
    "Aset Tetap": [
      "Ringkasan Aset Tetap",
      "Detil Aset Tetap",
      "Pelepasan Aset",
    ],
    "Anggaran": [
      "Anggaran Laba Rugi",
    ],
    "Lain-lain": [
      "Attachment",
      "Ekspor",
      "Import",
    ],
  };

  LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const KledoDrawer(), // Tambahkan drawer kalau diperlukan
      appBar: AppBar(
        title: const Text('Laporan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: laporanKategori.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey[300],
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...entry.value.map((laporan) => Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.star_border),
                              title: Text(laporan),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                if (laporan == "Neraca") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NeracaPage(),
                                    ),
                                  );
                                } else if (laporan == "Arus Kas") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArusKasPage(),
                                    ),
                                  );
                                } else if (laporan == "Laba Rugi") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LabaRugiPage(),
                                    ),
                                  );
                                } else if (laporan == "Perubahan Modal") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PerubahanModalPage()));
                                } else if (laporan == "Trial Balance") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrialBalancePage()));
                                } else if (laporan == "Detail Penjualan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DetailPenjualanPage()));
                                } else if (laporan == "Penjualan per Produk") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PenjualanPerProdukPage()));
                                } else if (laporan == "Profibilitas Produk") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfitabilitasProdukPage()));
                                } else if (laporan == "Tagihan Pelanggan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TagihanPelangganPage()));
                                } else if (laporan == "Ringkasan Eksekutif") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RingkasanEksekutif()));
                                } else if (laporan ==
                                    "Hutang Piutang per Kontak") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Hutangpiutangperkontak()));
                                } else if (laporan ==
                                    "Pelunasan Pembayaran Tagihan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PelunasanListPage()));
                                } else if (laporan == "Ringkasan Inventori") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const InventorySummaryPage()));
                                } else if (laporan == "Ringkasan Aset Tetap") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AsetRingkasanPage()));
                                } else if (laporan == "Pelepasan Aset") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PelepasanAsetPage()));
                                } else if (laporan == "Detil Aset Tetap") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DetilAsetTetapPage(),
                                      ));
                                } else if (laporan == "Ringkasan Stok Gudang") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RingkasanStokGudangPage(),
                                      ));
                                } else if (laporan == "Pajak Penjualan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PajakPenjualanPage(),
                                      ));
                                } else if (laporan == "Ringkasan Bank") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RingkasanBank(),
                                      ));
                                } else if (laporan == "Buku Besar") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BukuBesarScreen(),
                                      ));
                                } else if (laporan == "Pajak Pemotongan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PajakPemotonganPage(),
                                      ));
                                } else if (laporan ==
                                    "Pendapatan per Pelanggan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PendapatanPerpelangganPage(),
                                      ));
                                } else if (laporan == "Jurnal") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const JurnalListPage(),
                                      ));
                                } else if (laporan ==
                                    "Penjualan Produk per Pelanggan") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SalesListPage(),
                                      ));
                                } else if (laporan ==
                                    "Penjualan per Kategori Produk") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PenjualanPerKategoriPage(),
                                      ));
                                } else if (laporan == "Penjualan per Periode") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PenjualanPerPeriodePage(),
                                      ));
                                } else if (laporan == "Umur Piutang") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UmurPiutangPage(),
                                      ));
                                } else if (laporan == "Biaya per Kontak") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Biayaperkontak(),
                                      ));
                                } else if (laporan ==
                                    "Pergerakan Stok Inventori") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InventoryMovementPage(),
                                      ));
                                } else if (laporan ==
                                    "Pergerakan Stok Gudang") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const StockMovementPage(),
                                      ));
                                } else if (laporan == "Pembelian per Periode") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PembelianPerPeriodePage(),
                                      ));
                                } else if (laporan == "Pembelian per Produk") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PembelianPerProdukPage(),
                                      ));
                                }
                              },
                            ),
                            const Divider(height: 1),
                          ],
                        )),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
