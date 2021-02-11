import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supplier/utils/colors.dart';

class DashboardSummaryBtn extends StatelessWidget {
  DashboardSummaryBtn(
      {this.context,
      this.title,
      this.description,
      this.icon,
      this.next,
      this.callback,
      this.press});
  final title;
  final String description;
  final IconData icon;
  final press;
  final next;
  final BuildContext context;
  final VoidCallback callback;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.35,
          height: MediaQuery.of(context).size.width * 0.35,
          child: InkWell(
            onTap: () {
              navigate(press);
            },
            child: Card(
              elevation: 5,
              color: Color(0xffF5F5F5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.4)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      title.toString(),
                      style: GoogleFonts.comfortaa(
                          fontSize: 40,
                          color: purpleColor,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      description.toString(),
                      style: GoogleFonts.comfortaa(color: purpleColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          height: 40,
          child: new InkWell(
            onTap: () {
              navigate(next);
            },
            child: new CircleAvatar(
              child: new Icon(icon),
              backgroundColor: purpleColor,
              foregroundColor: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  navigate(page) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => page));
  }
}
