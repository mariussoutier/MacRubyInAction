//
//  main.m
//  TwitterContactImporter
//
//  Created by Marius Soutier on 27.08.11.
//  Copyright 2011 STAR Healthcare Management GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
