SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- -----------------------------------------------------
-- Schema loja_database
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `loja_database` DEFAULT CHARACTER SET utf8 ;
USE `loja_database` ;

-- -----------------------------------------------------
-- Table `loja_database`.`CATEGORIA`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `loja_database`.`CATEGORIA` (
  `ID_CATEGORIA` INT NOT NULL AUTO_INCREMENT,
  `NOME_CATEGORIA` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`ID_CATEGORIA`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `loja_database`.`PRODUTO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `loja_database`.`PRODUTO` (
  `ID_PRODUTO` INT NOT NULL AUTO_INCREMENT,
  `NOME_PRODUTO` VARCHAR(100) NOT NULL,
  `DESC_PRODUTO` VARCHAR(1000) NOT NULL,
  `PRECO_PRODUTO` DECIMAL(8) NOT NULL,
  `CATEGORIA_ID_CATEGORIA` INT NOT NULL,
  PRIMARY KEY (`ID_PRODUTO`, `CATEGORIA_ID_CATEGORIA`),
  INDEX `fk_PRODUTO_CATEGORIA_idx` (`CATEGORIA_ID_CATEGORIA` ASC),
  CONSTRAINT `fk_PRODUTO_CATEGORIA`
    FOREIGN KEY (`CATEGORIA_ID_CATEGORIA`)
    REFERENCES `loja_database`.`CATEGORIA` (`ID_CATEGORIA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `loja_database`.`CLIENTE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `loja_database`.`CLIENTE` (
  `ID_CLIENTE` INT NOT NULL AUTO_INCREMENT,
  `NOME_CLIENTE` VARCHAR(45) NULL,
  PRIMARY KEY (`ID_CLIENTE`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `loja_database`.`PEDIDO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `loja_database`.`PEDIDO` (
  `ID_PEDIDO` INT NOT NULL AUTO_INCREMENT,
  `DATA_PEDIDO` DATE NOT NULL,
  `ENDERECO_PEDIDO` VARCHAR(1000) NOT NULL,
  `TOTAL_PEDIDO` DECIMAL(10) NOT NULL,
  `CLIENTE_ID_CLIENTE` INT NOT NULL,
  PRIMARY KEY (`ID_PEDIDO`, `CLIENTE_ID_CLIENTE`),
  INDEX `fk_PEDIDO_CLIENTE1_idx` (`CLIENTE_ID_CLIENTE` ASC),
  CONSTRAINT `fk_PEDIDO_CLIENTE1`
    FOREIGN KEY (`CLIENTE_ID_CLIENTE`)
    REFERENCES `loja_database`.`CLIENTE` (`ID_CLIENTE`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `loja_database`.`ITEM_PEDIDO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `loja_database`.`ITEM_PEDIDO` (
  `ID_ITEM_PEDIDO` INT NOT NULL AUTO_INCREMENT,
  `QUANTIDADE_ITEM_PEDIDO` INT NOT NULL,
  `PRODUTO_ID_PRODUTO` INT NOT NULL,
  `PEDIDO_FINAL_ID_PEDIDO_FINAL` INT NOT NULL,
  PRIMARY KEY (`ID_ITEM_PEDIDO`, `PRODUTO_ID_PRODUTO`, `PEDIDO_FINAL_ID_PEDIDO_FINAL`),
  INDEX `fk_ITEM_PEDIDO_PRODUTO1_idx` (`PRODUTO_ID_PRODUTO` ASC),
  INDEX `fk_ITEM_PEDIDO_PEDIDO_FINAL1_idx` (`PEDIDO_FINAL_ID_PEDIDO_FINAL` ASC),
  CONSTRAINT `fk_ITEM_PEDIDO_PRODUTO1`
    FOREIGN KEY (`PRODUTO_ID_PRODUTO`)
    REFERENCES `loja_database`.`PRODUTO` (`ID_PRODUTO`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ITEM_PEDIDO_PEDIDO_FINAL1`
    FOREIGN KEY (`PEDIDO_FINAL_ID_PEDIDO_FINAL`)
    REFERENCES `loja_database`.`PEDIDO` (`ID_PEDIDO`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

DELIMITER $$
CREATE PROCEDURE INSERE_CATEGORIAS (IN QTD_REGISTROS INT)
BEGIN
DECLARE contador INT DEFAULT 0;
loop_categoria: LOOP
    SET contador = contador + 1;
    INSERT INTO CATEGORIA(NOME_CATEGORIA) VALUES(concat('CATEGORIA', contador));
    IF contador >= QTD_REGISTROS THEN
        LEAVE loop_categoria;
    END IF;
END LOOP loop_categoria;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE INSERE_PRODUTOS (IN QTD_REGISTROS INT)
BEGIN
DECLARE contador INT DEFAULT 0;
DECLARE linhasCat INT;
DECLARE random INT;
DECLARE preco DECIMAL;
SELECT COUNT(*) INTO linhasCat FROM CATEGORIA;
loop_produto: LOOP
	SELECT FLOOR (1 + RAND() * (linhasCat - 1)) INTO random;
    SELECT FLOOR (1 + RAND() * (200 - 1)) INTO preco;
    SET contador = contador + 1;
    INSERT INTO PRODUTO(NOME_PRODUTO, DESC_PRODUTO, PRECO_PRODUTO, CATEGORIA_ID_CATEGORIA) VALUES(concat('PRODUTO', contador), concat('DESCRIÇÃO', contador), preco, random);
    IF contador >= QTD_REGISTROS THEN
        LEAVE loop_produto;
    END IF;
END LOOP loop_produto;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE INSERE_CLIENTES (IN QTD_REGISTROS INT)
BEGIN
DECLARE contador INT DEFAULT 0;
loop_cliente: LOOP
    SET contador = contador + 1;
    INSERT INTO CLIENTE(NOME_CLIENTE) VALUES(concat('CLIENTE', contador));
    IF contador >= QTD_REGISTROS THEN
        LEAVE loop_cliente;
    END IF;
END LOOP loop_cliente;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE INSERE_PEDIDOS (IN QTD_REGISTROS INT)
BEGIN
DECLARE contador INT DEFAULT 0;
DECLARE linhasCli INT;
DECLARE random INT;
SELECT COUNT(*) INTO linhasCli FROM CLIENTE;
loop_pedido: LOOP
	SELECT FLOOR (1 + RAND() * (linhasCli - 1)) INTO random;
    SET contador = contador + 1;
    INSERT INTO PEDIDO(DATA_PEDIDO, ENDERECO_PEDIDO, TOTAL_PEDIDO, CLIENTE_ID_CLIENTE) VALUES(CURDATE(), concat('ENDEREÇO', contador), 0.0, random);
    IF contador >= QTD_REGISTROS THEN
        LEAVE loop_pedido;
    END IF;
END LOOP loop_pedido;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE INSERE_ITEM_PEDIDO (IN QTD_REGISTROS INT)
BEGIN
DECLARE contador INT DEFAULT 0;
DECLARE linhasPro INT;
DECLARE linhasPed INT;
DECLARE randomPro INT;
DECLARE randomPed INT;
DECLARE quantidade INT;
DECLARE preco FLOAT;
SELECT COUNT(*) INTO linhasPro FROM PRODUTO;
SELECT COUNT(*) INTO linhasPed FROM PEDIDO;
loop_item_pedido: LOOP
	SELECT FLOOR (1 + RAND() * (linhasPro - 1)) INTO randomPro;
    SELECT FLOOR (1 + RAND() * (linhasPed - 1)) INTO randomPed;
    SELECT FLOOR (1 + RAND() * (50 - 1)) INTO quantidade;
    SET contador = contador + 1;
    INSERT INTO ITEM_PEDIDO(QUANTIDADE_ITEM_PEDIDO, PRODUTO_ID_PRODUTO, PEDIDO_FINAL_ID_PEDIDO_FINAL) VALUES(quantidade, randomPro, contador);
    SELECT PRECO_PRODUTO INTO preco FROM PRODUTO WHERE ID_PRODUTO = randomPro;
    UPDATE PEDIDO SET TOTAL_PEDIDO = quantidade*preco WHERE ID_PEDIDO = contador;
    IF contador >= QTD_REGISTROS THEN
        LEAVE loop_item_pedido;
    END IF;
END LOOP loop_item_pedido;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE INSERE_DADOS_ALEATORIOS (IN QTD_REGISTROS INT)
BEGIN
CALL INSERE_CATEGORIAS(QTD_REGISTROS);
CALL INSERE_PRODUTOS(QTD_REGISTROS);
CALL INSERE_CLIENTES(QTD_REGISTROS);
CALL INSERE_PEDIDOS(QTD_REGISTROS);
CALL INSERE_ITEM_PEDIDO(QTD_REGISTROS);
END $$
DELIMITER ;

CALL INSERE_DADOS_ALEATORIOS(50);

SELECT * FROM CLIENTE;
SELECT * FROM CATEGORIA;
SELECT * FROM PRODUTO;
SELECT * FROM ITEM_PEDIDO;
SELECT * FROM PEDIDO;

