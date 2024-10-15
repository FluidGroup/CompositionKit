import StorybookKit

@MainActor
let book = Book(title: "MyBook") {

  Book_NavigationHostingView.body

  if #available(iOS 13, *) {
    Book_VGridView.body
  }
  
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
