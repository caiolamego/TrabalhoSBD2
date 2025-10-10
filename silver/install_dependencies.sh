#!/bin/bash
# Script para instalar dependências corretas para notebooks silver
# Execute: bash install_dependencies.sh

set -e  # Exit on error

echo "=========================================="
echo "Installing Silver Layer Dependencies"
echo "=========================================="
echo ""

PYTHON_CMD="python3.11"

# Verificar se Python 3.11 existe
if ! command -v $PYTHON_CMD &> /dev/null; then
    echo "❌ Python 3.11 not found!"
    echo "   Install with: sudo apt install python3.11"
    exit 1
fi

echo "🐍 Using: $($PYTHON_CMD --version)"
echo ""

# Desinstalar versões antigas/incompatíveis
echo "🔧 Step 1: Removing old/incompatible packages..."
$PYTHON_CMD -m pip uninstall -y numpy pandas psycopg2 psycopg2-binary 2>/dev/null || true
echo "✅ Old packages removed"
echo ""

# Instalar versões corretas
echo "🔧 Step 2: Installing correct versions..."
echo "   Installing numpy==1.26.4 (CRITICAL: must be 1.x for pandas 2.0.3)"
$PYTHON_CMD -m pip install --user "numpy==1.26.4"

echo "   Installing pandas==2.0.3"
$PYTHON_CMD -m pip install --user "pandas==2.0.3"

echo "   Installing psycopg2-binary==2.9.9"
$PYTHON_CMD -m pip install --user "psycopg2-binary==2.9.9"

echo "   Installing pyspark==3.5.1"
$PYTHON_CMD -m pip install --user "pyspark==3.5.1"

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""

# Verificar instalação
echo "📋 Verification:"
$PYTHON_CMD -c "
import numpy
import pandas
import psycopg2
import pyspark

print(f'  numpy: {numpy.__version__}')
print(f'  pandas: {pandas.__version__}')
print(f'  psycopg2: {psycopg2.__version__}')
print(f'  pyspark: {pyspark.__version__}')

# Check compatibility
numpy_major = int(numpy.__version__.split('.')[0])
if numpy_major >= 2:
    print('')
    print('⚠️  WARNING: numpy 2.x detected!')
    print('   This is INCOMPATIBLE with pandas 2.0.3')
    exit(1)
else:
    print('')
    print('✅ All packages compatible!')
"

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Open your Jupyter notebook"
echo "2. Restart the kernel (Menu → Kernel → Restart Kernel)"
echo "3. Skip diagnostic/install cells (1-6)"
echo "4. Start from Cell 7 (Environment Setup)"
echo "5. Execute cells 7-31 in sequence"
echo ""
