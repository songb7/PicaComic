import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pica_comic/network/models.dart';
import 'package:pica_comic/views/category_comic_page.dart';
import 'package:pica_comic/views/comic_reading_page.dart';
import 'package:pica_comic/views/commends_page.dart';
import 'package:pica_comic/views/widgets.dart';

import 'base.dart';

class ComicPageLogic extends GetxController{
  bool isLoading = true;
  ComicItem? comicItem;
  var tags = <Widget>[];
  var categories = <Widget>[];
  var eps = <Widget>[
    const ListTile(
      leading: Icon(Icons.library_books),
      title: Text("章节"),
    ),
  ];
  var epsStr = <String>[""];
  void change(){
    isLoading = !isLoading;
    update();
  }
}

class ComicPage extends StatelessWidget{
  final ComicItemBrief comic;
  ComicPage(this.comic, {super.key});
  final comicPageLogic = Get.put(ComicPageLogic());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ComicPageLogic>(builder: (comicPageLogic){
        if(comicPageLogic.isLoading){
          network.getComicInfo(comic.id).then((c){
            if(c!=null){
              comicPageLogic.comicItem = c;
              for(String s in c.tags){
                comicPageLogic.tags.add(GestureDetector(
                  onTap: (){Get.to(()=>CategoryComicPage(s));},
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),child: Text(s),),
                  ),
                ));
              }
              for(String s in c.categories){
                comicPageLogic.categories.add(GestureDetector(
                  onTap: (){Get.to(()=>CategoryComicPage(s));},
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),child: Text(s),),
                  ),
                ));
              }
              network.getEps(comic.id).then((e){
                for(int i = 1;i < e.length;i++){
                  comicPageLogic.epsStr.add(e[i]);
                  comicPageLogic.eps.add(ListTile(
                    title: Text(e[i]),
                    onTap: (){
                      Get.to(()=>ComicReadingPage(comic.id, i, comicPageLogic.epsStr));
                    },
                  ));
                }
                comicPageLogic.change();
              });
            }
          });
          return const Center(
            child: CircularProgressIndicator(),
          );
        }else if(comicPageLogic.comicItem!=null){
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(comic.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
                actions: [
                  Tooltip(
                    message: "更多",
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ListTile(
                                    title: const Text("标题"),
                                    subtitle: SelectableText(comic.title),
                                  ),
                                  ListTile(
                                    title: const Text("作者"),
                                    subtitle: SelectableText(comic.author),
                                  ),
                                  ListTile(
                                    title: const Text("上传者"),
                                    subtitle: SelectableText(comicPageLogic.comicItem!.creator.name),
                                  ),
                                  ListTile(
                                    title: const Text("汉化组"),
                                    subtitle: SelectableText(comicPageLogic.comicItem!.chineseTeam),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),)
                ],
              ),
              SliverToBoxAdapter(
                child: CachedNetworkImage(
                  imageUrl: comic.path,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  height: 300,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: FilledButton(
                        onPressed: (){
                          //Todo: 下载功能
                          showMessage(context, "下载功能还没做");
                        },
                        child: const Text("下载"),
                      ),),
                      SizedBox.fromSize(size: const Size(10,1),),
                      Expanded(child: FilledButton(
                        onPressed: (){
                          Get.to(()=>ComicReadingPage(comic.id, 1, comicPageLogic.epsStr));
                        },
                        child: const Text("阅读"),
                      ),),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Row(
                    children: [
                      Expanded(child: ActionChip(
                        label: Text(comicPageLogic.comicItem!.likes.toString()),
                        avatar: Icon((comicPageLogic.comicItem!.isLiked)?Icons.favorite:Icons.favorite_border),
                        onPressed: (){
                          network.likeOrUnlikeComic(comic.id);
                          comicPageLogic.comicItem!.isLiked = !comicPageLogic.comicItem!.isLiked;
                          comicPageLogic.update();
                        },
                      ),),
                      SizedBox.fromSize(size: const Size(10,1),),
                      Expanded(child: ActionChip(
                        label: const Text("收藏"),
                        avatar: Icon((comicPageLogic.comicItem!.isFavourite)?Icons.bookmark:Icons.bookmark_outline),
                        onPressed: (){
                          network.favouriteOrUnfavoriteComic(comic.id);
                          comicPageLogic.comicItem!.isFavourite = !comicPageLogic.comicItem!.isFavourite;
                          comicPageLogic.update();
                        },
                      ),),
                      SizedBox.fromSize(size: const Size(10,1),),
                      Expanded(child: ActionChip(
                        label: Text(comicPageLogic.comicItem!.comments.toString()),
                        avatar: const Icon(Icons.comment),
                        onPressed: (){
                          Get.to(()=>CommendsPage(comic.id));
                        },
                      ),),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                  child: Text("    分类"),
                ),
              ),
              SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Wrap(
                      children: comicPageLogic.categories,
                    ),
                  )
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                  child: Text("    标签"),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Wrap(
                    children: comicPageLogic.tags,
                  ),
                )
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Card(
                    child: Column(
                      children: comicPageLogic.eps,
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height/2-80,
                left: 0,
                right: 0,
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.error_outline,size:60,),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height/2-10,
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Text("网络错误"),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height/2+20,
                left: MediaQuery.of(context).size.width/2-50,
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: FilledButton(
                    onPressed: (){
                      comicPageLogic.change();
                    },
                    child: const Text("重试"),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

class ComicInfoTile extends StatelessWidget {
  final String title;
  final String content;
  const ComicInfoTile(this.title,this.content,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: const TextStyle(fontWeight: FontWeight.w600),),
          Text(content)
        ],
      ),
    );
  }
}

