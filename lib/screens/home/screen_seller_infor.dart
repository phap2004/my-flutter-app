import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/screens/home/screen_seller_home.dart';
import 'package:login_app/screens/sing-in/screen_signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenSellerInfor extends StatefulWidget {
  const ScreenSellerInfor({super.key});

  @override
  State<ScreenSellerInfor> createState() => _ScreenSellerInforState();
}

class _ScreenSellerInforState extends State<ScreenSellerInfor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shippingFeeController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();

  int currentStep = 0; // bước hiện tại
  String? selectedCarrier;

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ScreenSignin()),
      (route) => false,
    );
  }

  Future<void> saveSellerData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final sellerData = {
      'user_id': user.uid,
      'shop_name': shopNameController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'email': emailController.text,
      'shipping_carrier': selectedCarrier,
      'shipping_fee': shippingFeeController.text,
      'tax_code': taxController.text,
      'company_name': companyController.text,
      'id_number': idController.text,
      'issue_date': issueDateController.text,
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .set(sellerData);

      //Hiển thị thông báo lưu thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thông tin thành công!')),
      );

      //Chuyển sang trang Seller Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ScreenSellerHome()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu dữ liệu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD65F30),
        title: const Text(
          'Thông tin cửa hàng',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildStepBar(currentStep),
                const SizedBox(height: 30),
                buildFormForStep(currentStep), // form thay đổi
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Quay lại
                    if (currentStep > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD65F30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (currentStep > 0) {
                              currentStep--;
                            }
                          });
                        },
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    else
                      const SizedBox(
                        width: 100,
                      ), // giữ cân layout nếu ở bước đầu
                    // Nút Tiếp tục / Hoàn tất
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD65F30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (currentStep < 4) {
                          setState(() => currentStep++);
                        } else {
                          await saveSellerData(); //lưu dữ liệu vào Firestore
                        }
                      },
                      child: Text(
                        currentStep == 4 ? 'Hoàn tất' : 'Tiếp tục',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Thanh tiến trình
  Widget buildStepBar(int currentStep) {
    final steps = [
      'Thông tin Shop',
      'Cài đặt vận chuyển',
      'Thông tin thuế',
      'Thông tin định danh',
      'Hoàn tất',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD65F30)
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1,
                        color: index < currentStep
                            ? const Color(0xFFD65F30)
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? const Color(0xFFD65F30) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Form cho từng bước
  Widget buildFormForStep(int step) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputField(
              'Tên cửa hàng',
              'Nhập tên cửa hàng',
              shopNameController,
            ),
            const SizedBox(height: 20),
            buildInputField(
              'Địa chỉ lấy hàng',
              'Nhập địa chỉ',
              addressController,
            ),
            const SizedBox(height: 20),
            buildInputField(
              'Số điện thoại',
              'Nhập số điện thoại',
              phoneController,
            ),
            const SizedBox(height: 20),
            buildInputField('Email', 'Nhập email', emailController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn vị vận chuyển', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            //ComboBox (Dropdown)
            DropdownButtonFormField<String>(
              decoration: inputDecoration('Chọn đơn vị vận chuyển'),
              value: selectedCarrier,
              items: const [
                DropdownMenuItem(
                  value: 'GHN',
                  child: Text('Giao Hàng Nhanh (GHN)'),
                ),
                DropdownMenuItem(
                  value: 'GHTK',
                  child: Text('Giao Hàng Tiết Kiệm (GHTK)'),
                ),
                DropdownMenuItem(value: 'VTPost', child: Text('Viettel Post')),
                DropdownMenuItem(value: 'J&T', child: Text('J&T Express')),
                DropdownMenuItem(value: 'NinjaVan', child: Text('Ninja Van')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCarrier = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            buildInputField(
              'Phí vận chuyển mặc định',
              'Nhập số tiền',
              shippingFeeController,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputField('Mã số thuế', 'Nhập mã số thuế', taxController),
            const SizedBox(height: 20),
            buildInputField(
              'Tên công ty',
              'Nhập tên công ty',
              companyController,
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputField('CMND/CCCD', 'Nhập số định danh', idController),
            const SizedBox(height: 20),
            buildInputField('Ngày cấp', 'DD/MM/YYYY', issueDateController),
          ],
        );
      case 4:
        return const Center(
          child: Text(
            'Hoàn tất thiết lập cửa hàng!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Widget input
  Widget buildInputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 10),
        TextField(controller: controller, decoration: inputDecoration(hint)),
      ],
    );
  }

  // Style input
  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD65F30), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
