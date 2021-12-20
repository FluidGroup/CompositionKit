import StorybookKit

let book = Book(title: "MyBook") {

  Book_NavigationHostingView.body

  BookNavigationLink(title: "Demo") {
//    BookPush(title: "Demo") {
//      DemoViewController()
//    }
//    BookPush(title: "Threads") {
//      DemoThreadsMessagesViewController()
//    }
  }
}
