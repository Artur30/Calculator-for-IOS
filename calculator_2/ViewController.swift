//
//  ViewController.swift
//  calculator_2
//
//  Created by Артур Гумиров on 13.07.16.
//  Copyright © 2016 Артур Гумиров. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var tochka: UIButton! {
        didSet {
            tochka.setTitle(decimalSeparator, forState: UIControlState.Normal)
        }
    }
    
    let decimalSeparator =  NSNumberFormatter().decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            
            //----- Не пускаем избыточную точку ---------------
            if (digit == decimalSeparator) && (display.text?.rangeOfString(decimalSeparator) != nil)
            { return }
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //--------------------------------------------------
            
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            addHistory(operation + " =")
            
            switch operation {
                
            case "×": performOperation { $0 * $1 }
            case "÷": performOperation { $1 / $0 }
            case "+": performOperation { $0 + $1 }
            case "−": performOperation { $1 - $0 }
            case "√": performOperation (sqrt)
            case "sin": performOperation (sin)
            case "cos": performOperation (cos)
            case "π": performOperation   { M_PI }
            case "±": performOperation   { -$0 }
            default: break
                
            }
        }
    }
    
    @nonobjc func performOperation (operation: () -> Double ){
        displayValue = operation ()
        addStack()
    }
    
    @nonobjc func performOperation (operation: Double -> Double ){
        if operandStack.count >= 1 {
            displayValue = operation (operandStack.removeLast())
            addStack()
        } else {
            displayValue = nil
        }
    }
    
    @nonobjc func performOperation (operation: (Double, Double) -> Double ){
        if operandStack.count >= 2 {
            displayValue = operation (operandStack.removeLast() , operandStack.removeLast())
            addStack()
        } else {
            displayValue = nil
        }
    }
    
    
    var operandStack = Array <Double>()
    
    func addStack(){
        if let value = displayValue {
            operandStack.append(value)
            
        } else {
            displayValue = nil
        }
        print("operandStack = \(operandStack)")
    }
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        addHistory(display.text!)
        addStack()
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        history.text =  " "
        operandStack.removeAll()
        displayValue = 0
    }
    
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!).characters.count > 1 {
                display.text = String((display.text!).characters.dropLast())
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return numberFormatter().numberFromString(displayText)?.doubleValue
            }
            return nil
        }
        set {
            if (newValue != nil) {
                display.text = numberFormatter().stringFromNumber(newValue!)
            } else {
                display.text = " "
                history.text =  history.text! + " Error"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    func numberFormatter () -> NSNumberFormatter{
        let numberFormatterLoc = NSNumberFormatter()
        numberFormatterLoc.numberStyle = .DecimalStyle
        numberFormatterLoc.maximumFractionDigits = 10
        numberFormatterLoc.notANumberSymbol = "Error"
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
    func addHistory(text: String){
        
        // Удаляем знак =
        history.text = history.text!.rangeOfString("=") != nil
            ? (history.text!).stringByReplacingOccurrencesOfString("=", withString: "",
                                                                   options: [], range: nil)
            :  history.text
        
        // Удаляем Error
        history.text = history.text!.rangeOfString("Error") != nil
            ? (history.text!).stringByReplacingOccurrencesOfString("Error", withString: "",
                                                                   options: [], range: nil)
            :  history.text
        
        //Добавляем text
        history.text =  history.text! + " " + text
    }
    
}

