import 'package:flutter/material.dart';
class DrawerTile extends StatelessWidget {

  final IconData icon;
  final String text;
  final PageController pageController;
  final int page;

  DrawerTile(this.icon, this.text, this.pageController, this.page);

  @override
  Widget build(BuildContext context) {


    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
//            print('entrou1');
//            print(page);
            Navigator.of(context).pop();
//            if(page == 6) {
//              print('entrou');
//              ScopedModelDescendant<UserModel>(
//                  builder: (context, child, model) {
//                    model.signOut();
//                    Navigator.of(context).push(
//                      MaterialPageRoute(
//                          builder: (context) => LoginScreen()
//                      ),
//                    );
//                  }
//              );
//            }else{
              pageController.jumpToPage(page);
//            }
        },
        child: Container(
          height: 60.0,
          child: Row(
            children: <Widget>[
              Icon(icon, size: 32.0, color: pageController.page.round() == page ? Colors.white : Colors.white),
              SizedBox(width: 32.0,),
              Text(text, style: TextStyle(fontSize: 16.0, color: pageController.page.round() == page ? Colors.white : Colors.white),)
            ],
          ),
        ),
      ),
    );
  }
}
