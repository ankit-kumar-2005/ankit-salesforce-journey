// calculator.js
import { LightningElement, track } from 'lwc';

const MAX_INPUT_LENGTH = 36;
const MAX_DISPLAY_LENGTH = 12;

export default class Calculator extends LightningElement {
    @track input = '';
    @track result = '';
    @track showAC = true; // Initially AC
    lastOperator = '';
    operatorPressed = false;

    connectedCallback() {
        // Focus the calculator after component renders
        setTimeout(() => {
            const calculatorEl = this.template.querySelector('.calculator');
            if (calculatorEl) {
                calculatorEl.focus();
            }
        }, 100);
    }

    // Dynamic label for first button
    get backspaceOrAC() {
        return this.showAC ? 'AC' : '⌫';
    }

    handleClick(event) {
        const value = event.target.dataset.value;
        
        // Handle different button types
        if (['+', '-', '*', '/'].includes(value)) {
            this.handleOperator(value);
        } else if (value === '+/-') {
            this.handleToggleSign();
        } else if (value === '%') {
            this.handlePercent();
        } else if (value === '.') {
            this.handleDecimal();
        } else {
            this.handleNumber(value);
        }
    }

    handleNumber(value) {
        // Prevent input if max length reached
        if (this.input.replace(/[^0-9.]/g, '').length >= MAX_INPUT_LENGTH) {
            return;
        }

        // Clear result when starting new calculation after equals
        if (this.result && !this.operatorPressed) {
            this.input = value;
            this.result = '';
        } else {
            this.input += value;
        }
        
        this.showAC = false;
        this.operatorPressed = false;
        this.adjustFontSize();
    }

    handleOperator(operator) {
        if (this.input === '') return;
        
        // If there's already a complete expression, calculate it first
        if (this.input && !this.operatorPressed && this.lastOperator) {
            this.calculateResult();
        }
        
        // Prevent consecutive operators
        if (!this.operatorPressed) {
            this.input += operator;
            this.lastOperator = operator;
            this.operatorPressed = true;
            this.showAC = false;
            this.adjustFontSize();
        }
    }

    handleDecimal() {
        // Get the current number being typed
        const parts = this.input.split(/[+\-*/]/);
        const currentNumber = parts[parts.length - 1];
        
        // Add decimal only if current number doesn't have one
        if (!currentNumber.includes('.')) {
            if (this.input === '' || this.operatorPressed) {
                this.input += '0.';
            } else {
                this.input += '.';
            }
            this.showAC = false;
            this.operatorPressed = false;
            this.adjustFontSize();
        }
    }

    handleToggleSign() {
        if (this.input === '') return;
        
        // Get the current number being typed
        const parts = this.input.split(/([+\-*/])/);
        const lastPart = parts[parts.length - 1];
        
        if (lastPart && !isNaN(lastPart)) {
            if (lastPart.startsWith('-')) {
                parts[parts.length - 1] = lastPart.substring(1);
            } else {
                parts[parts.length - 1] = '-' + lastPart;
            }
            this.input = parts.join('');
            this.adjustFontSize();
        }
    }

    handlePercent() {
        if (this.input === '') return;
        
        try {
            // Get the current number being typed
            const parts = this.input.split(/([+\-*/])/);
            const lastPart = parts[parts.length - 1];
            
            if (lastPart && !isNaN(lastPart)) {
                const percentValue = (parseFloat(lastPart) / 100).toString();
                parts[parts.length - 1] = percentValue;
                this.input = parts.join('');
                this.adjustFontSize();
            }
        } catch (error) {
            this.result = 'Error';
            this.adjustFontSize();
        }
    }

    handleEqual() {
        this.calculateResult();
        this.showAC = true;
        this.lastOperator = '';
        this.operatorPressed = false;
    }

    calculateResult() {
        if (this.input === '') return;
        
        try {
            // eslint-disable-next-line no-eval
            let calculatedResult = eval(this.input);
            
            // Handle special cases
            if (calculatedResult === Infinity) {
                this.result = 'Infinity';
            } else if (calculatedResult === -Infinity) {
                this.result = '-Infinity';
            } else if (isNaN(calculatedResult)) {
                this.result = 'Error';
            } else {
                // Handle very small numbers (close to zero)
                if (Math.abs(calculatedResult) < 1e-15) {
                    calculatedResult = 0;
                }
                
                // Apply precision for normal numbers
                if (typeof calculatedResult === 'number' && isFinite(calculatedResult)) {
                    calculatedResult = +calculatedResult.toPrecision(15);
                }
                
                // Format the result for display
                this.result = this.formatNumber(calculatedResult.toString());
            }
            
            // Set input to result for further calculations
            this.input = this.result.toString();
            this.adjustFontSize();
            
        } catch (error) {
            this.result = 'Error';
            this.adjustFontSize();
        }
    }

    handleBackspaceOrAC() {
        if (this.showAC) {
            // AC → clear all
            this.input = '';
            this.result = '';
            this.lastOperator = '';
            this.operatorPressed = false;
        } else {
            // Backspace → delete last character
            this.input = this.input.slice(0, -1);
            if (this.input === '') {
                this.showAC = true;
                this.lastOperator = '';
                this.operatorPressed = false;
            }
        }
        this.adjustFontSize();
    }

    handleKeyDown(event) {
        const key = event.key;
        
        // Handle number input
        if (/\d/.test(key)) {
            this.handleNumber(key);
        }
        // Handle operators
        else if (['+', '-', '*', '/'].includes(key)) {
            this.handleOperator(key);
        }
        // Handle decimal point
        else if (key === '.') {
            this.handleDecimal();
        }
        // Handle equals/enter
        else if (key === 'Enter' || key === '=') {
            event.preventDefault();
            this.handleEqual();
        }
        // Handle backspace
        else if (key === 'Backspace') {
            this.handleBackspaceOrAC();
        }
        // Handle clear
        else if (key === 'Escape' || key.toLowerCase() === 'c') {
            this.showAC = true;
            this.handleBackspaceOrAC();
        }
        // Handle percentage
        else if (key === '%') {
            this.handlePercent();
        }
    }

    formatNumber(numStr) {
        // Limit the length of displayed numbers
        if (numStr.length > MAX_DISPLAY_LENGTH) {
            const num = parseFloat(numStr);
            if (Math.abs(num) >= 1e12 || (Math.abs(num) < 1e-6 && num !== 0)) {
                // Use scientific notation for very large or very small numbers
                return num.toExponential(6);
            } else {
                // Truncate decimal places
                return num.toPrecision(MAX_DISPLAY_LENGTH);
            }
        }
        return numStr;
    }

    adjustFontSize() {
        setTimeout(() => {
            const inputEl = this.template.querySelector('.input');
            const resultEl = this.template.querySelector('.result');
            
            if (inputEl) {
                const inputLength = this.input.length;
                inputEl.classList.remove('small-font', 'extra-small-font');
                
                if (inputLength > 15) {
                    inputEl.classList.add('extra-small-font');
                } else if (inputLength > 10) {
                    inputEl.classList.add('small-font');
                }
            }
            
            if (resultEl) {
                const resultLength = this.result.toString().length;
                resultEl.classList.remove('small-font', 'extra-small-font');
                
                if (resultLength > 12) {
                    resultEl.classList.add('extra-small-font');
                } else if (resultLength > 8) {
                    resultEl.classList.add('small-font');
                }
            }
        }, 0);
    }
}