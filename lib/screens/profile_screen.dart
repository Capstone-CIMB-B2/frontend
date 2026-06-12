import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../services/api_service.dart';
import '../models/user.dart';

// Helper for formatting Indonesian currency
String formatRupiah(double amount) {
  final valStr = amount.toInt().toString();
  final sb = StringBuffer();
  for (int i = 0; i < valStr.length; i++) {
    if (i > 0 && (valStr.length - i) % 3 == 0) {
      sb.write('.');
    }
    sb.write(valStr[i]);
  }
  return 'Rp ${sb.toString()}';
}

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _fetchUpdatedProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProfile();
      if (data != null && mounted) {
        setState(() {
          _user = UserModel.fromJson(data);
        });
        widget.onProfileUpdated();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Column(
            children: [
              const _ProfileSubHeader(title: 'Profile'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          label: 'KTP & Data Diri',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KtpDataDiriScreen(user: _user),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                        _ProfileMenuItem(
                          label: 'Alamat',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AlamatScreen(
                                  user: _user,
                                  onProfileUpdated: _fetchUpdatedProfile,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                        _ProfileMenuItem(
                          label: 'Pendidikan & Pekerjaan',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PendidikanPekerjaanScreen(user: _user),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                        _ProfileMenuItem(
                          label: 'Alamat Email',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EmailScreen(user: _user),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                        _ProfileMenuItem(
                          label: 'Nomor Telepon Terdaftar',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhoneScreen(
                                  user: _user,
                                  onProfileUpdated: _fetchUpdatedProfile,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD90002)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub Screen: KTP & Data Diri (Read-Only)
// ─────────────────────────────────────────────
class KtpDataDiriScreen extends StatelessWidget {
  final UserModel? user;
  const KtpDataDiriScreen({super.key, required this.user});

  void _showReadOnlyAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informasi KTP & Data Diri tidak dapat diubah oleh pengguna.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDob = user?.dob ?? '';
    if (formattedDob.isNotEmpty) {
      try {
        final parts = formattedDob.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final monthInt = int.tryParse(parts[1]) ?? 1;
          final day = parts[2];
          final months = [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ];
          final monthStr = months[monthInt - 1];
          formattedDob = '${int.parse(day)} $monthStr $year';
        }
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          const _ProfileSubHeader(title: 'KTP & Data Diri'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _DetailCard(
                    label: 'NIK',
                    value: user?.nik ?? '',
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                  _DetailCard(
                    label: 'Nama Lengkap',
                    value: user?.fullName ?? '',
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                  _DetailCard(
                    label: 'Tempat Lahir',
                    value: user?.birthPlace ?? '',
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                  _DetailCard(
                    label: 'Tanggal Lahir',
                    value: formattedDob,
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub Screen: Alamat (Editable)
// ─────────────────────────────────────────────
class AlamatScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onProfileUpdated;

  const AlamatScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  late UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _updateField(String key, String value, String label) async {
    setState(() => _isLoading = true);
    try {
      final success = await ApiService.updateProfile({key: value});
      if (success) {
        final data = await ApiService.getProfile();
        if (data != null && mounted) {
          setState(() {
            _user = UserModel.fromJson(data);
          });
          widget.onProfileUpdated();
        }
        if (mounted) {
          await _showSuccessDialog(context, '$label berhasil diperbarui.');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui $label. Coba lagi.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editAlamat() {
    _showEditDialog(
      context: context,
      title: 'Ubah Alamat',
      labelText: 'Alamat',
      initialValue: _user?.address ?? '',
      onSave: (val) => _updateField('street_address', val, 'Alamat'),
    );
  }

  void _editKota() {
    _showEditDialog(
      context: context,
      title: 'Ubah Kota / Kabupaten',
      labelText: 'Kota / Kabupaten',
      initialValue: _user?.city ?? '',
      onSave: (val) => _updateField('city', val, 'Kota / Kabupaten'),
    );
  }

  void _editProvinsi() {
    _showEditDialog(
      context: context,
      title: 'Ubah Provinsi',
      labelText: 'Provinsi',
      initialValue: _user?.province ?? '',
      onSave: (val) => _updateField('province', val, 'Provinsi'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Column(
            children: [
              const _ProfileSubHeader(title: 'Alamat'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      _DetailCard(
                        label: 'Alamat',
                        value: _user?.address ?? '',
                        onTap: _editAlamat,
                      ),
                      _DetailCard(
                        label: 'Kota / Kabupaten',
                        value: _user?.city ?? '',
                        onTap: _editKota,
                      ),
                      _DetailCard(
                        label: 'Provinsi',
                        value: _user?.province ?? '',
                        onTap: _editProvinsi,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD90002)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub Screen: Pendidikan & Pekerjaan (Read-Only)
// ─────────────────────────────────────────────
class PendidikanPekerjaanScreen extends StatelessWidget {
  final UserModel? user;
  const PendidikanPekerjaanScreen({super.key, required this.user});

  void _showReadOnlyAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informasi Pendidikan & Pekerjaan tidak dapat diubah oleh pengguna.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = user?.monthlyIncome ?? 0.0;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          const _ProfileSubHeader(title: 'Pendidikan & Pekerjaan'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _DetailCard(
                    label: 'Pekerjaan',
                    value: user?.occupation ?? '',
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                  _DetailCard(
                    label: 'Pendapatan Bulanan',
                    value: formatRupiah(income),
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub Screen: Alamat Email (Read-Only)
// ─────────────────────────────────────────────
class EmailScreen extends StatelessWidget {
  final UserModel? user;
  const EmailScreen({super.key, required this.user});

  void _showReadOnlyAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informasi Alamat Email tidak dapat diubah oleh pengguna.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          const _ProfileSubHeader(title: 'Alamat Email'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _DetailCard(
                    label: 'Alamat Email',
                    value: user?.emailAddress ?? '',
                    onTap: () => _showReadOnlyAlert(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub Screen: Nomor Telepon Terdaftar (Editable)
// ─────────────────────────────────────────────
class PhoneScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onProfileUpdated;

  const PhoneScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  late UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _updatePhone(String newPhone) async {
    setState(() => _isLoading = true);
    try {
      final success = await ApiService.updateProfile({'phone_number': newPhone});
      if (success) {
        final data = await ApiService.getProfile();
        if (data != null && mounted) {
          setState(() {
            _user = UserModel.fromJson(data);
          });
          widget.onProfileUpdated();
        }
        if (mounted) {
          await _showSuccessDialog(context, 'Nomor telepon berhasil diperbarui.');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui nomor telepon. Coba lagi.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editPhone() {
    _showEditDialog(
      context: context,
      title: 'Ubah Nomor Telepon',
      labelText: 'Nomor Telepon',
      initialValue: _user?.phoneNumber ?? '',
      isPhone: true,
      onSave: _updatePhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Column(
            children: [
              const _ProfileSubHeader(title: 'Nomor Telepon Terdaftar'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      _DetailCard(
                        label: 'Nomor Telepon Terdaftar',
                        value: _user?.phoneNumber ?? '',
                        onTap: _editPhone,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD90002)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENTS
// ─────────────────────────────────────────────
class _ProfileSubHeader extends StatelessWidget {
  final String title;
  const _ProfileSubHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/background/bg-header.svg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCC0000),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DetailCard({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E2E6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCC0000),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required String initialValue,
  required Function(String) onSave,
  bool isPhone = false,
}) async {
  final controller = TextEditingController(text: initialValue);
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCC0000)),
                    ),
                  ),
                  keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                  style: const TextStyle(color: Colors.black87),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '$labelText tidak boleh kosong';
                    }
                    if (isPhone) {
                      final digitsOnly = val.replaceAll(RegExp(r'\D'), '');
                      if (digitsOnly.length < 10 || digitsOnly.length > 14) {
                        return 'Nomor HP harus 10-14 digit';
                      }
                      if (RegExp(r'^(\d)\1+$').hasMatch(digitsOnly)) {
                        return 'Nomor HP tidak valid';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFFCC0000),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx);
                            onSave(controller.text.trim());
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showSuccessDialog(BuildContext context, String message) async {
  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'Berhasil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
