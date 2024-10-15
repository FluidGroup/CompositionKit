import StorybookKit

@MainActor
let book = Book(title: "MyBook") {

  Book_NavigationHostingView.body
  
  Book.dynamicAnimator

  BookNavigationLink(title: "Demo") {
//    BookPush(title: "Demo") {
//      DemoViewController()
//    }
//    BookPush(title: "Threads") {
//      DemoThreadsMessagesViewController()
//    }
  }
}
