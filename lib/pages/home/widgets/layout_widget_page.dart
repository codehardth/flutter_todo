import 'package:flutter/material.dart';

// สร้างหน้าจอ Flutter ที่แสดงผลธงชาติของประเทศไทย, สวีเดน, และญี่ปุ่น
// โดยใช้ Widget หลักในการออกแบบ ได้แก่ Column, Container, Row, Stack และ Padding
// รวมถึงการใช้ Custom Widget เพื่อแยกส่วนประกอบของแต่ละธงชาติ
class LayoutWidgetPage extends StatelessWidget {
  const LayoutWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // สร้าง spacerWidger เพื่อกำหนดระยะห่างระหว่าง Widget ด้วย Sizebox ขนาดสูง 20
    const spacerWidget = SizedBox(height: 20);

    // ใช้ SingleChildScrollView เพื่อให้หน้าจอเลื่อนดูได้ในกรณีที่เนื้อหาเกินขนาดหน้าจอ
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ThailandFlagWidget(),
              spacerWidget,
              SwedenFlagWidget(),
              spacerWidget,
              JapanFlagWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// widget สำหรับสร้างคำอธิบายเหนือธงขาติ โดยรับค่า String description มาแสดง
class CodeDescriptionWidget extends StatelessWidget {
  final String description;
  const CodeDescriptionWidget({
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.start,
      style: const TextStyle(
        color: Colors.green,
        fontSize: 15,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class ThailandFlagWidget extends StatelessWidget {
  const ThailandFlagWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CodeDescriptionWidget(
          description: 'วาดธงชาติไทยด้วย Column และ Container',
        ),
        Container(
          color: Colors.red,
          height: 35,
        ),
        Container(
          color: Colors.white,
          height: 35,
        ),
        Container(
          color: Colors.blue,
          height: 60,
        ),
        Container(
          color: Colors.white,
          height: 35,
        ),
        Container(
          color: Colors.red,
          height: 35,
        ),
      ],
    );
  }
}

class SwedenFlagWidget extends StatelessWidget {
  const SwedenFlagWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const yellowWidth = 35.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CodeDescriptionWidget(
          description: 'วาดธงชาติสวีเดนด้วยการใช้ Column, Row, และ Container เพื่อสร้างแถบสีฟ้าและสีเหลือง',
        ),
        blueAndYellow(yellowWidth),
        Container(
          color: Colors.yellow,
          height: yellowWidth,
        ),
        blueAndYellow(yellowWidth),
      ],
    );
  }

  // ฟังก์ชัน blueAndYellow สร้าง Container เพื่อช่วยลดความซ้ำซ้อนในการสร้างส่วนแถบสีสีน้ำเงินและเหลือง
  Container blueAndYellow(double yellowWidth) {
    return Container(
        height: 80,
        color: Colors.blueAccent,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: Container(
                color: Colors.yellow,
                width: yellowWidth,
              ),
            )
          ],
        ),
      );
  }
}

class JapanFlagWidget extends StatelessWidget {
  const JapanFlagWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CodeDescriptionWidget(
          description: 'วาดธงชาติญี่ปุ่นด้วย Stack และ Container (พร้อม BoxDecoration)',
        ),
        Stack(
          children: [
            Container(
              height: 200,
              color: Colors.white,
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
