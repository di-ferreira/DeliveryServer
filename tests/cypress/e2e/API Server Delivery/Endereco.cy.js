describe('Rotas Endereço', () => {

    let idEndereco01;
    let idEndereco02;

    before(() => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        });
    });

    it('Criar Endereço - 01', () => {
        cy.request({
            method: 'POST',
            url: '/cliente/55229785634/endereco',
            body: {
                "ID": 0,
                "CLIENTE": 4,
                "RUA": "Av. Country Clube dos Engenheiros",
                "NUMERO": "2042",
                "BAIRRO": "Clube dos Engenheiros",
                "COMPLEMENTO": "Casa 120",
                "CIDADE": "Araruama",
                "ESTADO": "RJ"
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].Message).to.equal('Endereço adicionado com sucesso!');
            expect(Response.body[1].RUA).to.equal('Av. Country Clube dos Engenheiros');
            expect(Response.body[1].BAIRRO).to.equal('Clube dos Engenheiros');
            idEndereco01 = Response.body[1].ID;
        });
    });

    it('Criar Endereço - 02', () => {
        cy.request({
            method: 'POST',
            url: '/cliente/55229785634/endereco',
            body: {
                "ID": 0,
                "RUA": "Rua Érica Reis",
                "NUMERO": "35",
                "BAIRRO": "Outeiro",
                "COMPLEMENTO": "Casa 4",
                "CIDADE": "Belford Roxo",
                "ESTADO": "RJ"
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].Message).to.equal('Endereço adicionado com sucesso!');
            expect(Response.body[1].RUA).to.equal('Rua Érica Reis');
            expect(Response.body[1].BAIRRO).to.equal('Outeiro');
            idEndereco02 = Response.body[1].ID;
        });
    });

    it('Buscar endereços de cliente', () => {
        cy.request('/cliente/55229785634/endereco')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.contato).to.equal('55229785634');
                expect(Response.body.ENDERECOS[0].rua).to.equal('Av. Country Clube dos Engenheiros');
                expect(Response.body.ENDERECOS[1].rua).to.equal('Rua Érica Reis');
            });
    });

    it('Buscar endereço por ID = 1', () => {
        cy.request(`/cliente/55229785634/endereco/${idEndereco01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idEndereco01);
            expect(Response.body.rua).to.equal('Av. Country Clube dos Engenheiros');
            expect(Response.body.bairro).to.equal('Clube dos Engenheiros');
            expect(Response.body.cidade).to.equal('Araruama');
        });
    });

    it('Buscar endereço por ID = 2', () => {
        cy.request(`/endereco/${idEndereco02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idEndereco02);
            expect(Response.body.rua).to.equal('Rua Érica Reis');
            expect(Response.body.bairro).to.equal('Outeiro');
            expect(Response.body.cidade).to.equal('Belford Roxo');
        });
    });

    it('Update endereço - 01', () => {
        cy.request({
            method: 'PUT',
            url: `/cliente/55229785634/endereco/${idEndereco01}`,
            body: {
                "ID": 1,
                "RUA": "Rua dos Gaúchos",
                "NUMERO": "200",
                "BAIRRO": "Vila Capri",
                "COMPLEMENTO": "",
                "CIDADE": "Araruama",
                "ESTADO": "RJ"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].Message).to.equal('Endereço atualizado com sucesso!');
            expect(Response.body[1].rua).to.equal('Rua dos Gaúchos');
            expect(Response.body[1].bairro).to.equal('Vila Capri');
            expect(Response.body[1].cidade).to.equal('Araruama');
        });
    });

    it('Update endereço - 02', () => {
        cy.request({
            method: 'PUT',
            url: `/endereco/${idEndereco02}`,
            body: {
                "ID": 2,
                "RUA": "Rua Nosso Senhor do Calvário",
                "NUMERO": "69",
                "BAIRRO": "Parque Amorim",
                "COMPLEMENTO": "",
                "CIDADE": "Belford Roxo",
                "ESTADO": "RJ"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].Message).to.equal('Endereço atualizado com sucesso!');
            expect(Response.body[1].rua).to.equal('Rua Nosso Senhor do Calvário');
            expect(Response.body[1].bairro).to.equal('Parque Amorim');
            expect(Response.body[1].cidade).to.equal('Belford Roxo');
        });
    });


    it('Delete endereço 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/cliente/55229785634/endereco/${idEndereco01}`
        }).then(Response => {
            expect(Response.status).to.equal(202);
            expect(Response.body.Message).to.equal('Endereço excluído!');
        });
    });

    it('Delete endereço 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/endereco/${idEndereco02}`
        }).then(Response => {
            expect(Response.status).to.equal(202);
            expect(Response.body.Message).to.equal('Endereço excluído!');
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/55229785634',
            failOnStatusCode: false
        });
    });

});