// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AccountsController from "./accounts_controller.js"
application.register("accounts", AccountsController)

import CategoriesController from "./categories_controller.js"
application.register("categories", CategoriesController)

import DropdownController from "./dropdown_controller.js"
application.register("dropdown", DropdownController)

import NavigationController from "./navigation_controller.js"
application.register("navigation", NavigationController)

import NotificationsController from "./notifications_controller.js"
application.register("notifications", NotificationsController)

import PageController from "./page_controller.js"
application.register("page", PageController)

import PlaidController from "./plaid_controller.js"
application.register("plaid", PlaidController)

import RelatedTransactionsController from "./related_transactions_controller.js"
application.register("related-transactions", RelatedTransactionsController)

import SearchController from "./search_controller.js"
application.register("search", SearchController)

import SubscriptionsController from "./subscriptions_controller.js"
application.register("subscriptions", SubscriptionsController)

import TfaController from "./tfa_controller.js"
application.register("tfa", TfaController)

import TransactionsController from "./transactions_controller.js"
application.register("transactions", TransactionsController)

import ChartsController from "./charts_controller.js"
application.register("charts", ChartsController)

import LinksController from "./links_controller.js"
application.register("links", LinksController)

import MessagesController from "./messages_controller.js"
application.register("messages", MessagesController)
